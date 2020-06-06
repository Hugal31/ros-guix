(define-module (ros kinetic urdfdom)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system python)
  #:use-module (gnu packages)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages web)
  #:use-module (gnu packages time)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages check)
  #:use-module (gnu packages apr)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages tls)
  #:use-module (console-bridge)
  #:use-module (ros kinetic base)
  #:use-module (ros kinetic ros-tools))

(define-public urdfdom-headers
  (package
    (name "urdfdom-headers")
    (version "1.0.0")
    (source
        (origin
          (method git-fetch)
          (uri (git-reference
                  (url "https://github.com/ros/urdfdom_headers.git")
                  (commit "1.0.0")))
          (file-name (git-file-name name version))
          (sha256
              (base32
                "1wm5q4yx6p09q6bqcdgmmrb9ayclhk8c1qii9wbgb91sg3jpdf8s"))))
    (build-system cmake-build-system)
    (arguments
      `(#:tests? #f))
    (home-page "https://wiki.ros.org/urdf")
    (synopsis "The URDF (U-Robot Description Format) headers provides core data structure headers for URDF.")
    (description "The URDF (U-Robot Description Format) headers provides core data structure headers for URDF.")
    (license license:bsd-3)))

(define-public urdfdom
  (package
    (name "urdfdom")
    (version "1.0.0")
    (source
        (origin
          (method git-fetch)
          (uri (git-reference
                  (url "https://github.com/ros/urdfdom.git")
                  (commit "1.0.0")))
          (file-name (git-file-name name version))
          (sha256
              (base32
                "0c82wb0cpblarwpll3zgks2h6syk05kcvplwv5irpgcmjg9qj246"))))
    (build-system cmake-build-system)
    (inputs
      `(("tinyxml" ,tinyxml)
        ("console-bridge" ,console-bridge)
        ("urdfdom-headers" ,urdfdom-headers)))
    (propagated-inputs
      `(("tinyxml" ,tinyxml)
        ("urdfdom-headers" ,urdfdom-headers)))
    (home-page "https://wiki.ros.org/urdf")
    (synopsis "The URDF (U-Robot Description Format) library provides core data structures and a simple XML parsers for populating the class data structures from an URDF file.")
    (description "This package contains a C++ parser for the Unified Robot Description Format (URDF), which is an XML format for representing a robot model. The code API of the parser has been through our review process and will remain backwards compatible in future releases.")
    (license license:bsd-3)))

(define-public urdf
  (package
    (name "urdf")
    (version "1.12.12")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/urdf-release.git")
               (commit "release/kinetic/urdf/1.12.12-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1dsvad8hym385lrjilbdhawgaxwv5qgxibm4d6fpxbm6a2mpixs2"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("urdfdom" ,urdfdom)
        ("urdfdom-headers" ,urdfdom-headers)
        ("rosconsole-bridge" ,rosconsole-bridge)
        ("roscpp" ,roscpp)
        ("urdf-parser-plugin" ,urdf-parser-plugin)
        ("pluginlib" ,pluginlib)
        ("cmake-modules" ,cmake-modules)
        ("tinyxml" ,tinyxml)))
    (propagated-inputs
      `(("urdfdom" ,urdfdom)
        ("rosconsole-bridge" ,rosconsole-bridge)
        ("roscpp" ,roscpp)
        ("pluginlib" ,pluginlib)
        ("tinyxml" ,tinyxml)))
    (home-page "http://ros.org/wiki/urdf")
    (synopsis
      "This package contains a C++ parser for the Unified Robot Description\n Format (URDF), which is an XML format for representing a robot model.\n The code API of the parser has been through our review process and will remain\n backwards compatible in future releases.")
    (description
      "This package contains a C++ parser for the Unified Robot Description\n Format (URDF), which is an XML format for representing a robot model.\n The code API of the parser has been through our review process and will remain\n backwards compatible in future releases.")
    (license license:bsd-3)))

(define-public srdfdom
  (package
    (name "srdfdom")
    (version "0.4.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/srdfdom-release.git")
               (commit "release/kinetic/srdfdom/0.4.2-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0c6ziwskfy6a5jhrk3a4w4wfsij296s307d4y5r227hrac2f1kv2"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("boost" ,boost)
        ("cmake-modules" ,cmake-modules)
        ("console-bridge" ,console-bridge)
        ("urdf" ,urdf)
        ("urdfdom-headers" ,urdfdom-headers)
        ("urdfdom-py" ,urdfdom-py)
        ("tinyxml" ,tinyxml)))
    (propagated-inputs
      `(("boost" ,boost)
        ("console-bridge" ,console-bridge)
        ("urdfdom-headers" ,urdfdom-headers)
        ("tinyxml" ,tinyxml)
        ("urdfdom-py" ,urdfdom-py)))
    (home-page "http://ros.org/wiki/srdfdom")
    (synopsis
      "Parser for Semantic Robot Description Format (SRDF).")
    (description
      "Parser for Semantic Robot Description Format (SRDF).")
    (license license:bsd-3)))

(define-public urdf-parser-plugin
  (package
    (name "urdf-parser-plugin")
    (version "1.12.12")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/urdf-release.git")
               (commit
                 "release/kinetic/urdf_parser_plugin/1.12.12-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0hrrl3y851a0lzqk0h9azk0n6ji07i7x07xdwcnr7xkbr899gjpm"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs `(("urdfdom-headers" ,urdfdom-headers)))
    (propagated-inputs
      `(("urdfdom-headers" ,urdfdom-headers)))
    (home-page "http://ros.org/wiki/urdf")
    (synopsis
      "This package contains a C++ base class for URDF parsers.")
    (description
      "This package contains a C++ base class for URDF parsers.")
    (license license:bsd-3)))

(define-public urdfdom-py
  (package
    (name "urdfdom-py")
    (version "0.3.3")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/urdfdom_py-release.git")
               (commit "release/kinetic/urdfdom_py/0.3.3-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1nn40raww18kz0wylssrk9pkgpyx0wvrb18y4pkk15xgbqs26sgm"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("python2-catkin-pkg" ,python2-catkin-pkg)))
    (inputs `(("python" ,python)))
    (propagated-inputs
      `(("catkin" ,catkin)
        ("python" ,python)
        ("python2-lxml" ,python2-lxml)))
    (home-page "http://wiki.ros.org/urdf_parser_py")
    (synopsis
      "Python implementation of the URDF parser.")
    (description
      "Python implementation of the URDF parser.")
    (license license:bsd-3)))
