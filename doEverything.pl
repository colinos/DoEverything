#!/usr/local/bin/perl

# takes a directory of selected images as an argument
# necessary rotations (or cropping) should already be completed
# as well as having activeperl, imagemagick, perlmagick installed
# edits images (sharpen?, resize, compress)
# creates thumbnails, creates html page for each image
# may need to edit html pages with subject, location info
# need to link main page to first html page in new image directory

use Image::Magick;

# make sure a directory argument has been supplied
if ($ARGV[0] eq "") {
    print "usage: perl doEverything.pl ImageDir\n";
} else {

# get rid of unix slash from "tab-completing" dir name
if ($ARGV[0] =~ /(.+)\//) {
    $dir = $1;
} else {
    $dir = $ARGV[0];
}

# create array of images to process
@imageList = <$dir/*.jp*g>;
foreach $image (@imageList) {
    $image =~ /$dir\/(.+)/;
    $image = $1;
}
@imageListTable = @imageList;

# perform necessary image editing
mkdir("$dir/$dir", 0777);
foreach $image (@imageList) {
    $magickImage = Image::Magick->new;
    $magickImage->Read(filename=>"$dir/$image");

    # sharpen
#    $magickImage->UnsharpMask(radius=>'0', sigma=>'1', amount=>'100', threshold=>'0.008');
    # resize
    if (($magickImage->Get('height') > ($magickImage->Get('width') * 2)) || ($magickImage->Get('width') > ($magickImage->Get('height') * 2))) {
        if (($magickImage->Get('height') > 900) || ($magickImage->Get('width') > 900)) {
            $magickImage->Resize(geometry=>'900x900');
        } else {
            # do nothing (at least for the moment)
        }
    } else {
        $magickImage->Resize(geometry=>'500x500');
    }
    # compress
    $magickImage->Set(quality=>'60');

    $magickImage->Write(filename=>"$dir/$dir/$image");
    undef $magickImage;
}

# create directory of thumbnail images
mkdir("$dir/$dir/Thumbs", 0777);
foreach $image (@imageList) {
    $magickImage = Image::Magick->new;
    $magickImage->Read(filename=>"$dir/$image");

    $magickImage->Resize(geometry=>'100x100');
    $magickImage->Set(quality=>'60');

    $magickImage->Write(filename=>"$dir/$dir/Thumbs/$image");
    undef $magickImage;
}

# create html for index table of thumbnails
$table = "";
while (@imageListTable != ()) {
    ($image, @imageListTable) = @imageListTable;
    $image =~ /(.+)\.jpe?g/i;
    $htmlName = $1.".html";

    if (@imageListTable != ()) {
        ($nextImage, @imageListTable) = @imageListTable;
        $nextImage =~ /(.+)\.jpe?g/i;
        $nextHtmlName = $1.".html";

        $table = $table."\
 <tr align=\"center\">\
  <td><a href=\"$htmlName\"><img src=\"Thumbs/$image\" border=\"0\"></a></td>\
  <td><a href=\"$nextHtmlName\"><img src=\"Thumbs/$nextImage\" border=\"0\"></a></td>\
 </tr>";
    } else {
        $table = $table."\
 <tr align=\"center\">\
  <td><a href=\"$htmlName\"><img src=\"Thumbs/$image\" border=\"0\"></a></td>\
  <td></td>\
 </tr>";
    }
}
$table = "<table cellpadding=\"3\">".$table."\n</table>";

# create html page for each image
while (@imageList != ()) {
    ($image, @imageList) = @imageList;

    if (@imageList != ()) {
        ($nextImage, @imageListIgnore) = @imageList;
        $nextImage =~ /(.+)\.jpe?g/i;
        $links = "<img src=\"../next.gif\">&nbsp;<a href=\"$1.html\">Next</a>&nbsp;&nbsp;&nbsp;\
   <img src=\"../next.gif\">&nbsp;<a href=\"../route.html\">Return</a>";
    } else {
        $links = "<img src=\"../next.gif\">&nbsp;<a href=\"../route.html\">Return</a>";
    }

    $image =~ /(.+)\.jpe?g/i;
    $outfile = "$dir/$dir/$1.html";
    open(OUT, ">$outfile");

    print OUT <<"EOT";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
  <title>colinosullivan.com</title>
  <link rel="stylesheet" type="text/css" href="../style.css">
 </head>

 <body>
<table cellpadding="10" width="100%">
 <tr valign="top">
  <td>
   $links<br><br>
   <img src="$image"><br><br>
   <!-- image subject<br> -->
   <!-- image location<br><br> -->
   All images &copy; Colin O'Sullivan
  </td>
  <td align="right">
$table
  </td>
 </tr>
</table>
 </body>
</html>
EOT

    close(OUT);
}

} # end of command line argument check
