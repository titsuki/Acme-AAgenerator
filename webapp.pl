use Mojolicious::Lite;
use Text::AAlib qw/:all/;
use Imager;
use Data::Dumper;

get '/' => sub {
    my $self = shift;
    $self->render('index');
};

post '/convert' => sub {
    my $self = shift;

# Check file size
    return $self->render(text => 'File is too big.', status => 200)
	if $self->req->is_limit_exceeded;

    my $up = $self->param('upload');
    $up->move_to('/tmp/aagen.png');

    my $preview = "";
    if ($up) {
    	my $img = Imager->new();
    	$img->open( file => '/tmp/aagen.png', type => 'png') or die;
    	my ($width, $height) = ($img->getwidth, $img->getheight);
    	my $aa = Text::AAlib->new(
    	    width  => $width,
    	    height => $height,
    	    mask   => AA_REVERSE_MASK,
    	    );
    	$aa->put_image(image => $img);
    	$preview = $aa->render();
    }

    $self->render('convert',up => $preview);
    # return $self->redirect_to('/result');
};

get 'result' => sub {
    my $self = shift;
    $self->render(text => "result");
};

app->start;

__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<form action="convert" method="post" enctype="multipart/form-data">
filepath: <input type="file" name="upload">
    <input type="submit" value="Submit">
</form>
Welcome to the Mojolicious real-time web framework!

@@ convert.html.ep
% layout 'default';
% title 'Welcome';
<%= stash('up') %>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
