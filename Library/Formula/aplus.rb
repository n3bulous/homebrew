require 'formula'

class Aplus < Formula
  url 'http://mirrors.kernel.org/debian/pool/main/a/aplus-fsf/aplus-fsf_4.22.1.orig.tar.gz'
  homepage 'http://www.aplusdev.org/'
  md5 'c45df4f3e816d7fe957deed9b81f66c3'

  # Fix the missing CoreServices include (via Fink version of aplus)
  def patches
    DATA
  end

  def install
    # replace placeholder w/ actual prefix
    ["src/lisp.0/aplus.el", "src/lisp.1/aplus.el"].each do |path|
      chmod 0644, path
      inreplace path, "/usr/local/aplus-fsf-4.20", prefix
    end
    system "/usr/bin/aclocal -I config"
    system "/usr/bin/glibtoolize --force --copy"
    system "/usr/bin/automake --foreign --add-missing --copy"
    system "/usr/bin/autoconf"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "/usr/bin/make"
    # make install breaks with -j option
    ENV.j1
    system "/usr/bin/make", "install"
  end

  def caveats
    return <<-EOS.undent
    This package contains a custom APL font; it doesn't display APL characters
    using the usual Unicode codepoints.  Install it by running

    open #{prefix}/fonts/TrueType/KAPL.TTF

    and clicking on the "Install Font" button.
    EOS
  end
end


__END__
--- a/src/AplusGUI/AplusApplication.C	2010-11-28 17:06:58.000000000 -0800
+++ b/src/AplusGUI/AplusApplication.C	2010-11-28 17:06:31.000000000 -0800
@@ -5,6 +5,7 @@
 //
 //
 ///////////////////////////////////////////////////////////////////////////////
+#include <CoreServices/CoreServices.h>
 #include <MSGUI/MSTextField.H>
 #include <MSGUI/MSWidget.H>
 #include <MSIPC/MSTv.H>
