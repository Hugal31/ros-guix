(define-module (ros kinetic base)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system python)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages apr)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages image)
  #:use-module ((gnu packages image-processing) #:prefix image-processing:)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages time)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages photo)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages check)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages video)
  #:use-module (gnu packages web)
  #:use-module (gnu packages wxwidgets)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 match)
  #:use-module (log4cxx)
  #:use-module (console-bridge)
  #:use-module (ros kinetic ros-tools)
  #:use-module (ros kinetic poco)
  #:use-module (ros kinetic urdfdom))

(define-public boost
  (package
    (name "boost")
    (version "1.58.0")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "mirror://sourceforge/boost/boost_"
                    (string-map (lambda (x) (if (eq? x #\.) #\_ x)) version)
                    ".tar.bz2"))
              (sha256
               (base32
                "1rfkqxns60171q62cppiyzj8pmsbwp1l8jd7p6crriryqd7j1z7x"))
              (patches
               (search-patches
                "ros/kinetic/patches/boost/chrono-duration.patch"
                "ros/kinetic/patches/boost/pythonid.patch"
                "ros/kinetic/patches/boost/mpi-allocator-c++0x.patch"
                "ros/kinetic/patches/boost/fix-ftbfs-python-3.3.patch"
                "ros/kinetic/patches/boost/hppa-long-double-config.patch"
                "ros/kinetic/patches/boost/boost-python-examples.patch"
                "ros/kinetic/patches/boost/ppc64el-fp_traits-ibm-long-double.patch"
                "ros/kinetic/patches/boost/no-gcc-m-options.diff"
                "ros/kinetic/patches/boost/0002-Fix-a-regression-with-non-constexpr-types.patch"
                "ros/kinetic/patches/boost/ec60c37295146bb80aa44a92cf416027b75b5ff7.patch"
                "ros/kinetic/patches/boost/numeric-ublas-storage.hpp.patch"
                "ros/kinetic/patches/boost/openssl-no-ssl3.patch"
                "ros/kinetic/patches/boost/provide-missing-source-jquery.patch"
                "ros/kinetic/patches/boost/no-gcc-march-options.patch"
                "ros/kinetic/patches/boost/Changes-required-for-aarch64-support-in-boost-config.patch"))))
    (build-system gnu-build-system)
    (outputs '("out" "dev"))
    (inputs `(("zlib" ,zlib)))
    (native-inputs
     `(("perl" ,perl)
       ("python" ,python-2.7)
       ("tcsh" ,tcsh)))
    (arguments
     (let ((build-flags
            `("threading=multi" "link=shared"

              ;; Set the RUNPATH to $libdir so that the libs find each other.
              (string-append "linkflags=-Wl,-rpath="
                             (assoc-ref outputs "out") "/lib")

              ;; Boost's 'context' library is not yet supported on mips64, so
              ;; we disable it.  The 'coroutine' library depends on 'context',
              ;; so we disable that too.
              ,@(if (string-prefix? "mips64" (or (%current-target-system)
                                                 (%current-system)))
                    '("--without-context" "--without-coroutine")
                    '()))))
       `(#:tests? #f
         #:phases
         (modify-phases %standard-phases
           (delete 'bootstrap)
           (replace
            'configure
            (lambda* (#:key outputs #:allow-other-keys)
              (let ((out (assoc-ref outputs "out"))
                    (dev (assoc-ref outputs "dev")))
                (substitute* '("libs/config/configure"
                               "libs/spirit/classic/phoenix/test/runtest.sh"
                               "tools/build/doc/bjam.qbk"
                               "tools/build/src/engine/execunix.c"
                               "tools/build/src/engine/Jambase"
                               "tools/build/src/engine/jambase.c")
                  (("/bin/sh") (which "sh")))

                (setenv "SHELL" (which "sh"))
                (setenv "CONFIG_SHELL" (which "sh"))

                (unless (zero? (system* "./bootstrap.sh"
                                        (string-append "--prefix=" out)
                                        (string-append "--includedir=" dev "/include")
                                        "--with-toolset=gcc"))
                  (throw 'configure-error))
                #t)))
           (replace
            'build
            (lambda* (#:key outputs #:allow-other-keys)
              (zero? (system* "./b2" ,@build-flags))))
           (replace
            'install
            (lambda* (#:key outputs #:allow-other-keys)
              (zero? (system* "./b2" "install" ,@build-flags))))))))

    (home-page "http://boost.org")
    (synopsis "Peer-reviewed portable C++ source libraries")
    (description
     "A collection of libraries intended to be widely useful, and usable
across a broad spectrum of applications.")
    (license (license:x11-style "http://www.boost.org/LICENSE_1_0.txt"
"Some components have other similar licences."))))

(define-public roscpp
  (package
    (name "roscpp")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/roscpp/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0n82622sq2azn1hky3c7laxwdgfdrcbahbv5gabw4pm18x9razcr"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("boost:dev" ,boost "dev")))
    (inputs
     `(("boost" ,boost)
       ("cpp-common" ,cpp-common)
       ("message-generation" ,message-generation)
       ("pkg-config" ,pkg-config)
       ("rosconsole" ,rosconsole)
       ("roscpp-serialization" ,roscpp-serialization)
       ("roscpp-traits" ,roscpp-traits)
       ("rosgraph-msgs" ,rosgraph-msgs)
       ("roslang" ,roslang)
       ("rostime" ,rostime)
       ("std-msgs" ,std-msgs)
       ("xmlrpcpp" ,xmlrpcpp)))
    (propagated-inputs
     `(("cpp-common" ,cpp-common)
       ("message-runtime" ,message-runtime)
       ("rosconsole" ,rosconsole)
       ("rosgraph-msgs" ,rosgraph-msgs)
       ("roscpp-serialization" ,roscpp-serialization)
       ("rostime" ,rostime)
       ("std-msgs" ,std-msgs)
       ("xmlrpcpp" ,xmlrpcpp)))
    (home-page "http://ros.org/wiki/roscpp")
    (synopsis
      "roscpp is a C++ implementation of ROS. It provides\n a <a href=\"http://www.ros.org/wiki/Client%20Libraries\">client\n library</a> that enables C++ programmers to quickly interface with\n ROS <a href=\"http://ros.org/wiki/Topics\">Topics</a>,\n <a href=\"http://ros.org/wiki/Services\">Services</a>,\n and <a href=\"http://ros.org/wiki/Parameter Server\">Parameters</a>.\n\n roscpp is the most widely used ROS client library and is designed to\n be the high-performance library for ROS.")
    (description
      "roscpp is a C++ implementation of ROS. It provides\n a <a href=\"http://www.ros.org/wiki/Client%20Libraries\">client\n library</a> that enables C++ programmers to quickly interface with\n ROS <a href=\"http://ros.org/wiki/Topics\">Topics</a>,\n <a href=\"http://ros.org/wiki/Services\">Services</a>,\n and <a href=\"http://ros.org/wiki/Parameter Server\">Parameters</a>.\n\n roscpp is the most widely used ROS client library and is designed to\n be the high-performance library for ROS.")
    (license license:bsd-3)))

(define-public rosgraph-msgs
  (package
    (name "rosgraph-msgs")
    (version "1.11.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm_msgs-release.git")
               (commit "release/kinetic/rosgraph_msgs/1.11.2-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1acyvalskr9hk23g2rsavpanjvnhq1cz467lnymyh4xd5g7xkrza"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
     `(("cpp-common" ,cpp-common)
       ("message-generation" ,message-generation)
       ("roscpp-serialization" ,roscpp-serialization)
       ("std-msgs" ,std-msgs)))
    (propagated-inputs
     `(("message-runtime" ,message-runtime)
       ("std-msgs" ,std-msgs)))
    (home-page "http://ros.org/wiki/rosgraph_msgs")
    (synopsis
      "Messages relating to the ROS Computation Graph. These are generally considered to be low-level messages that end users do not interact with.")
    (description
      "Messages relating to the ROS Computation Graph. These are generally considered to be low-level messages that end users do not interact with.")
    (license license:bsd-3)))

(define-public rosconsole
  (package
    (name "rosconsole")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rosconsole/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1qyv4gncm30yakj2mybw99n9c4gn786w139d6bpsl4jscpk79mvm"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("boost:dev" ,boost "dev")))
    (inputs
      `(("apr" ,apr)
        ("boost" ,boost)
        ("cpp-common" ,cpp-common)
        ("log4cxx" ,log4cxx)
        ("rostime" ,rostime)
        ("rosunit" ,rosunit)))
    (propagated-inputs
      `(("apr" ,apr)
        ("cpp-common" ,cpp-common)
        ("log4cxx" ,log4cxx)
        ("rosbuild" ,rosbuild)
        ("rostime" ,rostime)))
    (home-page "http://www.ros.org/wiki/rosconsole")
    (synopsis "ROS console output library.")
    (description "ROS console output library.")
    (license license:bsd-3)))

(define-public cpp-common
  (package
    (name "cpp-common")
    (version "0.6.11")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/roscpp_core-release.git")
               (commit "release/kinetic/cpp_common/0.6.11-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1xr926154i7kspnj4sb32vxl4q4jm178ncazq0hhvviwwh46nxpy"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("boost:dev" ,boost "dev")))
    (inputs
      `(("boost" ,boost)
        ("console-bridge" ,console-bridge)))
    (home-page "http://www.ros.org/wiki/cpp_common")
    (synopsis
      "cpp_common contains C++ code for doing things that are not necessarily ROS\n related, but are useful for multiple packages. This includes things like\n the ROS_DEPRECATED and ROS_FORCE_INLINE macros, as well as code for getting\n backtraces.\n\n This package is a component of <a href=\"http://www.ros.org/wiki/roscpp\">roscpp</a>.")
    (description
      "cpp_common contains C++ code for doing things that are not necessarily ROS\n related, but are useful for multiple packages. This includes things like\n the ROS_DEPRECATED and ROS_FORCE_INLINE macros, as well as code for getting\n backtraces.\n\n This package is a component of <a href=\"http://www.ros.org/wiki/roscpp\">roscpp</a>.")
    (license license:bsd-3)))

(define-public xmlrpcpp
  (package
    (name "xmlrpcpp")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/xmlrpcpp/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1v7mr6pmnijp6bkaqya8z2brfk04a1rd2lyj8m5fim58k8k8g4i1"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("cpp-common" ,cpp-common) ("rostime" ,rostime)))
    (propagated-inputs
      `(("cpp-common" ,cpp-common) ("rostime" ,rostime)))
    (home-page "http://xmlrpcpp.sourceforge.net")
    (synopsis
      "XmlRpc++ is a C++ implementation of the XML-RPC protocol. This version is\n heavily modified from the package available on SourceForge in order to\n support roscpp's threading model. As such, we are maintaining our\n own fork.")
    (description
      "XmlRpc++ is a C++ implementation of the XML-RPC protocol. This version is\n heavily modified from the package available on SourceForge in order to\n support roscpp's threading model. As such, we are maintaining our\n own fork.")
    (license license:lgpl2.1)))

(define-public rostime
  (package
    (name "rostime")
    (version "0.6.11")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/roscpp_core-release.git")
               (commit "release/kinetic/rostime/0.6.11-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0500gr9y1vrwbhx2ihnyaprys7svpg2hxkk191y3x5b969lc8ibm"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("boost:dev" ,boost "dev")))
    (inputs
      `(("boost" ,boost) ("cpp-common" ,cpp-common)))
    (home-page "http://ros.org/wiki/rostime")
    (synopsis
      "Time and Duration implementations for C++ libraries, including roscpp.")
    (description
      "Time and Duration implementations for C++ libraries, including roscpp.")
    (license license:bsd-3)))

(define-public message-runtime
  (package
    (name "message-runtime")
    (version "0.4.12")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/message_runtime-release.git")
               (commit
                 "release/kinetic/message_runtime/0.4.12-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0mh60p1arv7gj0w0wgg3c4by76dg02nd5hkd4bh5g6pgchigr0qy"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("cpp-common" ,cpp-common)
        ("roscpp-serialization" ,roscpp-serialization)
        ("roscpp-traits" ,roscpp-traits)
        ("rostime" ,rostime)
        ("genpy" ,genpy)))
    (home-page "http://ros.org/wiki/message_runtime")
    (synopsis
      "Package modeling the run-time dependencies for language bindings of messages.")
    (description
      "Package modeling the run-time dependencies for language bindings of messages.")
    (license license:bsd-3)))

(define-public std-msgs
  (package
    (name "std-msgs")
    (version "0.5.11")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/std_msgs-release.git")
               (commit "release/kinetic/std_msgs/0.5.11-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0wb2c2m0c7ysfwmyanrkx7n1iy0xr7fawjp2vf6xmk5469jz2l9b"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("message-generation" ,message-generation)))
    (propagated-inputs
      `(("message-runtime" ,message-runtime)))
    (home-page "http://www.ros.org/wiki/std_msgs")
    (synopsis
      "Standard ROS Messages including common message types representing primitive data types and other basic message constructs, such as multiarrays.\n For common, generic robot-specific message types, please see <a href=\"http://www.ros.org/wiki/common_msgs\">common_msgs</a>.")
    (description
      "Standard ROS Messages including common message types representing primitive data types and other basic message constructs, such as multiarrays.\n For common, generic robot-specific message types, please see <a href=\"http://www.ros.org/wiki/common_msgs\">common_msgs</a>.")
    (license license:bsd-3)))

(define-public roscpp-serialization
  (package
    (name "roscpp-serialization")
    (version "0.6.11")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/roscpp_core-release.git")
               (commit
                 "release/kinetic/roscpp_serialization/0.6.11-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1rgw9xvnbc64gbxc7aw797hbq49v1ql783msyf2njda4fcmwzwpp"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("cpp-common" ,cpp-common)
        ("roscpp-traits" ,roscpp-traits)
        ("rostime" ,rostime)))
    (propagated-inputs
      `(("cpp-common" ,cpp-common)
        ("roscpp-traits" ,roscpp-traits)
        ("rostime" ,rostime)))
    (home-page
      "http://ros.org/wiki/roscpp_serialization")
    (synopsis
      "roscpp_serialization contains the code for serialization as described in\n <a href=\"http://www.ros.org/wiki/roscpp/Overview/MessagesSerializationAndAdaptingTypes\">MessagesSerializationAndAdaptingTypes</a>.\n\n This package is a component of <a href=\"http://www.ros.org/wiki/roscpp\">roscpp</a>.")
    (description
      "roscpp_serialization contains the code for serialization as described in\n <a href=\"http://www.ros.org/wiki/roscpp/Overview/MessagesSerializationAndAdaptingTypes\">MessagesSerializationAndAdaptingTypes</a>.\n\n This package is a component of <a href=\"http://www.ros.org/wiki/roscpp\">roscpp</a>.")
    (license license:bsd-3)))

(define-public roscpp-traits
  (package
    (name "roscpp-traits")
    (version "0.6.11")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/roscpp_core-release.git")
               (commit "release/kinetic/roscpp_traits/0.6.11-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0pgwzd2yzsqfap80n6wcnj0jip1z3cghw49mihyf8w0q3lfz6yf6"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("cpp-common" ,cpp-common) ("rostime" ,rostime)))
    (home-page "http://ros.org/wiki/roscpp_traits")
    (synopsis
      "roscpp_traits contains the message traits code as described in\n <a href=\"http://www.ros.org/wiki/roscpp/Overview/MessagesTraits\">MessagesTraits</a>.\n\n This package is a component of <a href=\"http://www.ros.org/wiki/roscpp\">roscpp</a>.")
    (description
      "roscpp_traits contains the message traits code as described in\n <a href=\"http://www.ros.org/wiki/roscpp/Overview/MessagesTraits\">MessagesTraits</a>.\n\n This package is a component of <a href=\"http://www.ros.org/wiki/roscpp\">roscpp</a>.")
    (license license:bsd-3)))

(define-public message-generation
  (package
    (name "message-generation")
    (version "0.4.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/message_generation-release.git")
               (commit
                 "release/kinetic/message_generation/0.4.0-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0vnwr3jx0dapmyqgiy7h4qxkf837cv1wacqpxm5j10c864vmcrb3"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("gencpp" ,gencpp)
        ("geneus" ,geneus)
        ("gennodejs" ,gennodejs)
        ("genlisp" ,genlisp)
        ("genmsg" ,genmsg)
        ("genpy" ,genpy)))
    (home-page
      "http://ros.org/wiki/message_generation")
    (synopsis
      "Package modeling the build-time dependencies for generating language bindings of messages.")
    (description
      "Package modeling the build-time dependencies for generating language bindings of messages.")
    (license license:bsd-3)))

(define-public roslang
  (package
    (name "roslang")
    (version "1.14.4")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros-release.git")
               (commit "release/kinetic/roslang/1.14.4-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "18p5ncr4qq3shhmrf3zsmx7sqpzli2n2k9lbb1s64fqljcwnzkd1"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("catkin" ,catkin) ("genmsg" ,genmsg)))
    (home-page "http://ros.org/wiki/roslang")
    (synopsis
      "roslang is a common package that all <a href=\"http://www.ros.org/wiki/Client%20Libraries\">ROS client libraries</a> depend on.\n This is mainly used to find client libraries (via 'rospack depends-on1 roslang').")
    (description
      "roslang is a common package that all <a href=\"http://www.ros.org/wiki/Client%20Libraries\">ROS client libraries</a> depend on.\n This is mainly used to find client libraries (via 'rospack depends-on1 roslang').")
    (license license:bsd-3)))

(define-public genlisp
  (package
    (name "genlisp")
    (version "0.4.16")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/genlisp-release.git")
               (commit "release/kinetic/genlisp/0.4.16-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0qndyl118h7y6amsydfaippb5lk1s2lbk38f4b88012522bgf1mf"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs `(("genmsg" ,genmsg)))
    (propagated-inputs `(("genmsg" ,genmsg)))
    (home-page "http://www.ros.org/wiki/roslisp")
    (synopsis
      "Common-Lisp ROS message and service generators.")
    (description
      "Common-Lisp ROS message and service generators.")
    (license license:bsd-3)))

(define-public genpy
  (package
    (name "genpy")
    (version "0.6.7")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/genpy-release.git")
               (commit "release/kinetic/genpy/0.6.7-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1mvyiwn98n07nfsd2igx8g7laink4c7g5f7g1ljqqpsighrxn5jd"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs `(("genmsg" ,genmsg)))
    (propagated-inputs
      `(("genmsg" ,genmsg)
        ("python2-pyyaml" ,python2-pyyaml)))
    (home-page "https://github.com/ros/genpy/issues")
    (synopsis
      "Python ROS message and service generators.")
    (description
      "Python ROS message and service generators.")
    (license license:bsd-3)))

(define-public genmsg
  (package
    (name "genmsg")
    (version "0.5.11")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/genmsg-release.git")
               (commit "release/kinetic/genmsg/0.5.11-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "04ya9x910yvbpk883y3cpw2kmbkg8l8hl808sh79cyk4ff6hd0wf"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs `(("catkin" ,catkin)))
    (home-page "http://www.ros.org/wiki/genmsg")
    (synopsis
      "Standalone Python library for generating ROS message and service data structures for various languages.")
    (description
      "Standalone Python library for generating ROS message and service data structures for various languages.")
    (license license:bsd-3)))

(define-public gencpp
  (package
    (name "gencpp")
    (version "0.6.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/gencpp-release.git")
               (commit "release/kinetic/gencpp/0.6.0-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1wjizls8h2qjjq8aliwqvxd86p2jzll4cq66grzf8j7aj3dxvyl2"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs `(("genmsg" ,genmsg)))
    (propagated-inputs `(("genmsg" ,genmsg)))
    (home-page
      "https://github.com/ros/gencpp/issues")
    (synopsis
      "C++ ROS message and service generators.")
    (description
      "C++ ROS message and service generators.")
    (license license:bsd-3)))

(define-public geneus
  (package
    (name "geneus")
    (version "2.2.6")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/tork-a/geneus-release.git")
               (commit "release/kinetic/geneus/2.2.6-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0gdw4ph0ixirkg0c1kp8lqdf9kpjfc59iakpf5i1cvy1fvff0kcd"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs `(("genmsg" ,genmsg)))
    (propagated-inputs `(("genmsg" ,genmsg)))
    (home-page "http://wiki.ros.org")
    (synopsis
      "EusLisp ROS message and service generators.")
    (description
      "EusLisp ROS message and service generators.")
    (license license:bsd-3)))

(define-public gennodejs
  (package
    (name "gennodejs")
    (version "2.0.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/RethinkRobotics-release/gennodejs-release.git")
               (commit "release/kinetic/gennodejs/2.0.1-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "077l2crbfq12dan5zg4hxi7x85m0nangmlxckh7a7ifggavzm7jh"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs `(("genmsg" ,genmsg)))
    (propagated-inputs `(("genmsg" ,genmsg)))
    (home-page "http://wiki.ros.org")
    (synopsis
      "Javascript ROS message and service generators.")
    (description
      "Javascript ROS message and service generators.")
    (license license:asl2.0)))

(define-public rosbuild
  (package
    (name "rosbuild")
    (version "1.14.4")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros-release.git")
               (commit "release/kinetic/rosbuild/1.14.4-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0xarzviz72yihmngy0wjz1lkra4xgx5zr11ddqw2xvsca8xsa4kw"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs `(("pkg-config" ,pkg-config)))
    (propagated-inputs
      `(("catkin" ,catkin)
        ("message-generation" ,message-generation)
        ("message-runtime" ,message-runtime)))
    (home-page "http://ros.org/wiki/rosbuild")
    (synopsis
      "rosbuild contains scripts for managing the CMake-based build system for ROS.")
    (description
      "rosbuild contains scripts for managing the CMake-based build system for ROS.")
    (license license:bsd-3)))

(define-public rosunit
  (package
    (name "rosunit")
    (version "1.14.4")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros-release.git")
               (commit "release/kinetic/rosunit/1.14.4-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0czgdsy7acg32a6vhshfk61m8gqay1qv65v8i9fi4r4zc235d0sh"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("python2-rospkg" ,python2-rospkg)
        ("roslib" ,roslib)))
    (home-page "http://ros.org/wiki/rosunit")
    (synopsis
      "Unit-testing package for ROS. This is a lower-level library for rostest and handles unit tests, whereas rostest handles integration tests.")
    (description
      "Unit-testing package for ROS. This is a lower-level library for rostest and handles unit tests, whereas rostest handles integration tests.")
    (license license:bsd-3)))

(define-public roslib
  (package
    (name "roslib")
    (version "1.14.4")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros-release.git")
               (commit "release/kinetic/roslib/1.14.4-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1a9xp0qfihhsls8ab89qdxvn4cr0kw4r7516ddi7h4d8j9cx9crd"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("boost:dev" ,boost "dev")))
    (inputs `(("boost" ,boost) ("rospack" ,rospack)))
    (propagated-inputs
      `(("catkin" ,catkin)
        ("python2-rospkg" ,python2-rospkg)
        ("python-empy" ,python-empy)
        ("python-catkin-pkg" ,python-catkin-pkg)
        ("ros-environment" ,ros-environment)
        ("rospack" ,rospack)))
    (home-page "http://ros.org/wiki/roslib")
    (synopsis
      "Base dependencies and support libraries for ROS.\n roslib contains many of the common data structures and tools that are shared across ROS client library implementations.")
    (description
      "Base dependencies and support libraries for ROS.\n roslib contains many of the common data structures and tools that are shared across ROS client library implementations.")
    (license license:bsd-3)))

(define-public ros-environment
  (package
    (name "ros-environment")
    (version "1.0.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_environment-release.git")
               (commit
                 "release/kinetic/ros_environment/1.0.0-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1q279cs8ifvfv1i5484n210zby8zbs1r8cbg21m50ld2lbnp5hrs"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (home-page
      "https://github.com/ros/ros_environment")
    (synopsis
      "The package provides the environment variables `ROS_VERSION`, `ROS_DISTRO`, `ROS_PACKAGE_PATH`, and `ROS_ETC_DIR`.")
    (description
      "The package provides the environment variables `ROS_VERSION`, `ROS_DISTRO`, `ROS_PACKAGE_PATH`, and `ROS_ETC_DIR`.")
    (license license:asl2.0)))

(define-public rospack
  (package
    (name "rospack")
    (version "2.4.4")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/rospack-release.git")
               (commit "release/kinetic/rospack/2.4.4-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0b5gvzzxpcw3cqkg2hzrzz2zq121jlk3wsii6za69v5ip8ij1a1d"))))
    (build-system cmake-build-system)
    (arguments
      `(#:tests? #f))
    (native-inputs
      `(("catkin" ,catkin)
        ("boost:dev" ,boost "dev")))
    (inputs
      `(("boost" ,boost)
        ("cmake-modules" ,cmake-modules)
        ("googletest" ,googletest)
        ("pkg-config" ,pkg-config)
        ("python" ,python)
        ("tinyxml" ,tinyxml)))
    (propagated-inputs
      `(("pkg-config" ,pkg-config)
        ("python" ,python)
        ("python2-catkin-pkg" ,python2-catkin-pkg)
        ("python2-rosdep" ,python2-rosdep)
        ("tinyxml" ,tinyxml)))
    (home-page "http://wiki.ros.org/rospack")
    (synopsis "ROS Package Tool")
    (description "ROS Package Tool")
    (license license:bsd-3)))

(define-public cmake-modules
  (package
    (name "cmake-modules")
    (version "0.4.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/cmake_modules-release.git")
               (commit "release/kinetic/cmake_modules/0.4.2-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "11kh2z059ffxgjzrzh9jgdln3fhydh799bc590kfgxcqjx0kqpli"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (home-page
      "https://github.com/ros/cmake_modules")
    (synopsis
      "A common repository for CMake Modules which are not distributed with CMake but are commonly used by ROS packages.")
    (description
      "A common repository for CMake Modules which are not distributed with CMake but are commonly used by ROS packages.")
    (license license:bsd-3)))

(define-public xacro
  (package
    (name "xacro")
    (version "1.11.3")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/xacro-release.git")
               (commit "release/kinetic/xacro/1.11.3-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0g1sx2nk2l5y9wi50cc07vdq0zibai1xgx2arhlhkdx3k0c8f6li"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs `(("roslint" ,roslint)))
    (propagated-inputs `(("roslaunch" ,roslaunch)))
    (home-page "http://ros.org/wiki/xacro")
    (synopsis
      "Xacro (XML Macros)\n\n Xacro is an XML macro language. With xacro, you can construct shorter and more readable XML files by using macros that expand to larger XML expressions.")
    (description
      "Xacro (XML Macros)\n\n Xacro is an XML macro language. With xacro, you can construct shorter and more readable XML files by using macros that expand to larger XML expressions.")
    (license license:bsd-3)))

(define-public octomap-msgs
  (package
    (name "octomap-msgs")
    (version "0.3.3")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/octomap_msgs-release.git")
               (commit "release/kinetic/octomap_msgs/0.3.3-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "15f2kl8dpvz77ihsz2dx75akady60kr242wqj1y1qi39vvhmp3ii"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("message-generation" ,message-generation)))
    (inputs
     `(("cpp-common" ,cpp-common)
       ("roscpp-serialization" ,roscpp-serialization)
       ("message-runtime" ,message-runtime)))
    (propagated-inputs
     `(("geometry-msgs" ,geometry-msgs)
       ("std-msgs" ,std-msgs)))
    (home-page "http://ros.org/wiki/octomap_msgs")
    (synopsis
      "This package provides messages and serializations / conversion for the <a href=\"http://octomap.github.com\">OctoMap library</a>.")
    (description
      "This package provides messages and serializations / conversion for the <a href=\"http://octomap.github.com\">OctoMap library</a>.")
    (license license:bsd-3)))

(define-public geometry-msgs
  (package
   (name "geometry-msgs")
   (version "1.12.7")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/ros-gbp/common_msgs-release.git")
           (commit "release/kinetic/geometry_msgs/1.12.7-0")))
     (file-name (git-file-name name version))
     (sha256
      (base32
       "0na2wvwd85h5zlwm32fjka1q03sqqrl39dmgcbj71z7p1hyzgijw"))))
   (build-system cmake-build-system)
   (native-inputs
    `(("catkin" ,catkin)
      ("message-generation" ,message-generation)))
   (inputs
    `(("cpp-common" ,cpp-common)
      ("message-runtime" ,message-runtime)
      ("roscpp-serialization" ,roscpp-serialization)))
   (propagated-inputs
    `(("std-msgs" ,std-msgs)))
   (home-page "http://wiki.ros.org/geometry_msgs")
   (synopsis
    "geometry_msgs provides messages for common geometric primitives\n such as points, vectors, and poses. These primitives are designed\n to provide a common data type and facilitate interoperability\n throughout the system.")
   (description
    "geometry_msgs provides messages for common geometric primitives\n such as points, vectors, and poses. These primitives are designed\n to provide a common data type and facilitate interoperability\n throughout the system.")
       (license license:bsd-3)))

(define-public sensor-msgs
  (package
    (name "sensor-msgs")
    (version "1.12.7")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/common_msgs-release.git")
               (commit "release/kinetic/sensor_msgs/1.12.7-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1a92rg3b63w5fqdld8ixnj8gibwl33snqfx2s6386bjllwmc9w48"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("message-generation" ,message-generation)))
    (inputs
     `(("cpp-common" ,cpp-common)
       ("geometry-msgs" ,geometry-msgs)
       ("roscpp-serialization" ,roscpp-serialization)
       ("std-msgs" ,std-msgs)))
    (propagated-inputs
     `(("geometry-msgs" ,geometry-msgs)
       ("message-runtime" ,message-runtime)
       ("std-msgs" ,std-msgs)))
    (home-page "http://ros.org/wiki/sensor_msgs")
    (synopsis
      "This package defines messages for commonly used sensors, including\n cameras and scanning laser rangefinders.")
    (description
      "This package defines messages for commonly used sensors, including\n cameras and scanning laser rangefinders.")
    (license license:bsd-3)))

(define-public shape-msgs
  (package
    (name "shape-msgs")
    (version "1.12.7")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/common_msgs-release.git")
               (commit "release/kinetic/shape_msgs/1.12.7-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "072wbwk1r7yz35ay669sh2lypys9wl1pr39dasx6b0a2hyvhx01v"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("message-generation" ,message-generation)))
    (inputs
     `(("cpp-common" ,cpp-common)
       ("roscpp-serialization" ,roscpp-serialization)))
    (propagated-inputs
     `(("geometry-msgs" ,geometry-msgs)
       ("message-runtime" ,message-runtime)
       ("std-msgs" ,std-msgs)))
    (home-page "http://wiki.ros.org/shape_msgs")
    (synopsis
      "This package contains messages for defining shapes, such as simple solid\n object primitives (cube, sphere, etc), planes, and meshes.")
    (description
      "This package contains messages for defining shapes, such as simple solid\n object primitives (cube, sphere, etc), planes, and meshes.")
    (license license:bsd-3)))

(define-public geometric-shapes
  (package
    (name "geometric-shapes")
    (version "0.5.4")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/geometric_shapes-release.git")
               (commit
                 "release/kinetic/geometric_shapes/0.5.4-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0nx876dbfm7d8fnhrifmrq56acx42d4fsxr8xwfw3s0cwzzp0pkr"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("boost:dev" ,boost "dev")
        ("eigen" ,eigen)
        ("eigen-stl-containers" ,eigen-stl-containers)))
    (inputs
      `(("assimp" ,assimp)
        ("boost" ,boost)
        ("console-bridge" ,console-bridge)
        ("qhull" ,qhull)
        ("octomap" ,octomap)
        ("pkg-config" ,pkg-config)
        ("random-numbers" ,random-numbers)
        ("resource-retriever" ,resource-retriever)
        ("shape-msgs" ,shape-msgs)
        ("visualization-msgs" ,visualization-msgs)))
    (propagated-inputs
      `(("assimp" ,assimp)
        ("qhull" ,qhull)
        ("octomap" ,octomap)
        ("random-numbers" ,random-numbers)
        ("resource-retriever" ,resource-retriever)
        ("shape-msgs" ,shape-msgs)
        ("visualization-msgs" ,visualization-msgs)))
    (home-page
      "http://ros.org/wiki/geometric_shapes")
    (synopsis
      "This package contains generic definitions of geometric shapes and bodies.")
    (description
      "This package contains generic definitions of geometric shapes and bodies.")
    (license license:bsd-3)))

(define-public eigen-conversions
  (package
    (name "eigen-conversions")
    (version "1.11.9")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/geometry-release.git")
               (commit
                 "release/kinetic/eigen_conversions/1.11.9-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "038m4brlzdlynkjprzywwfawdripck66ksilm8b2nncldxqyl35j"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
     `(("cmake-modules" ,cmake-modules)
       ("cpp-common" ,cpp-common)
       ("geometry-msgs" ,geometry-msgs)
       ("eigen" ,eigen)
       ("orocos-kdl" ,orocos-kdl)
       ("roscpp-serialization" ,roscpp-serialization)
       ("std-msgs" ,std-msgs)))
    (propagated-inputs
     `(("geometry-msgs" ,geometry-msgs)
       ("eigen" ,eigen)
       ("orocos-kdl" ,orocos-kdl)
       ("std-msgs" ,std-msgs)))
    (home-page
     "http://ros.org/wiki/eigen_conversions")
    (synopsis
     "Conversion functions between:\n - Eigen and KDL\n - Eigen and geometry_msgs.")
    (description
     "Conversion functions between:\n - Eigen and KDL\n - Eigen and geometry_msgs.")
    (license license:bsd-3)))

(define-public eigen-stl-containers
  (package
    (name "eigen-stl-containers")
    (version "0.1.8")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/eigen_stl_containers-release.git")
               (commit
                 "release/kinetic/eigen_stl_containers/0.1.8-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0qc38369y5adp96h48fv07mhqhgmxpwb6mk2ig1ywq2mphlicfyr"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("cmake-modules" ,cmake-modules)
        ("eigen" ,eigen)))
    (propagated-inputs `(("eigen" ,eigen)))
    (home-page
      "http://eigen.tuxfamily.org/dox/TopicUnalignedArrayAssert.html")
    (synopsis
      "This package provides a set of typedef's that allow\n using Eigen datatypes in STL containers")
    (description
      "This package provides a set of typedef's that allow\n using Eigen datatypes in STL containers")
    (license license:bsd-3)))

(define-public kdl-parser
  (package
    (name "kdl-parser")
    (version "1.12.11")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/kdl_parser-release.git")
               (commit "release/kinetic/kdl_parser/1.12.11-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "17kyyydblgmwk30pg7pwwpa09pdxnajpnishsym5ii28agmqd5d1"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("cmake-modules" ,cmake-modules)
        ("urdfdom-headers" ,urdfdom-headers)
        ("rosconsole" ,rosconsole)
        ("tinyxml" ,tinyxml)
        ("urdf" ,urdf)
        ("orocos-kdl" ,orocos-kdl)))
    (propagated-inputs
      `(("rosconsole" ,rosconsole)
        ("tinyxml" ,tinyxml)
        ("urdf" ,urdf)
        ("orocos-kdl" ,orocos-kdl)))
    (home-page "http://ros.org/wiki/kdl_parser")
    (synopsis
      "The Kinematics and Dynamics Library (KDL) defines a tree structure\n to represent the kinematic and dynamic parameters of a robot\n mechanism. <tt>kdl_parser</tt> provides tools to construct a KDL\n tree from an XML robot representation in URDF.")
    (description
      "The Kinematics and Dynamics Library (KDL) defines a tree structure\n to represent the kinematic and dynamic parameters of a robot\n mechanism. <tt>kdl_parser</tt> provides tools to construct a KDL\n tree from an XML robot representation in URDF.")
    (license license:bsd-3)))

(define-public octomap
  (package
    (name "octomap")
    (version "1.8.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/octomap-release.git")
               (commit "release/kinetic/octomap/1.8.1-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1wrkd5wjpxzy32rhgd969zg33vakhlipj7576asvnjmg5kwsvj6f"))))
    (build-system cmake-build-system)
    ; (native-inputs `(("cmake" ,cmake)))
    (propagated-inputs `(("catkin" ,catkin)))
    (home-page "http://octomap.github.io")
    (synopsis
      "The OctoMap library implements a 3D occupancy grid mapping approach, providing data structures and mapping algorithms in C++. The map implementation is based on an octree. See\n http://octomap.github.io for details.")
    (description
      "The OctoMap library implements a 3D occupancy grid mapping approach, providing data structures and mapping algorithms in C++. The map implementation is based on an octree. See\n http://octomap.github.io for details.")
    (license license:bsd-3)))

(define-public random-numbers
  (package
    (name "random-numbers")
    (version "0.3.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/random_numbers-release.git")
               (commit "release/kinetic/random_numbers/0.3.1-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "08nadnpz5qkb0ndk7nphqw3vvxfmy767pvr5nfa6mbipysylif7r"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("boost:dev" ,boost "dev")))
    (inputs `(("boost" ,boost)))
    (home-page "http://ros.org/wiki/random_numbers")
    (synopsis
      "This library contains wrappers for generating floating point values, integers, quaternions using boost libraries.\n \n The constructor of the wrapper is guaranteed to be thread safe and initialize its random number generator to a random seed.\n Seeds are obtained using a separate and different random number generator.")
    (description
      "This library contains wrappers for generating floating point values, integers, quaternions using boost libraries.\n \n The constructor of the wrapper is guaranteed to be thread safe and initialize its random number generator to a random seed.\n Seeds are obtained using a separate and different random number generator.")
    (license license:bsd-3)))

(define-public trajectory-msgs
  (package
    (name "trajectory-msgs")
    (version "1.12.7")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/common_msgs-release.git")
               (commit
                 "release/kinetic/trajectory_msgs/1.12.7-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1z41ywhia4l6ysd9zc4kxcillyk45r1bpl6hyfbb59pih1mkqi2y"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("message-generation" ,message-generation)))
    (inputs
     `(("cpp-common", cpp-common)
       ("roscpp-serialization" ,roscpp-serialization)
       ("message-runtime" ,message-runtime)
       ("rosbag-migration-rule" ,rosbag-migration-rule)))
    (propagated-inputs
      `(("geometry-msgs" ,geometry-msgs)
        ("std-msgs" ,std-msgs)))
    (home-page "http://wiki.ros.org/trajectory_msgs")
    (synopsis
      "This package defines messages for defining robot trajectories. These messages are\n also the building blocks of most of the\n <a href=\"http://wiki.ros.org/control_msgs\">control_msgs</a> actions.")
    (description
      "This package defines messages for defining robot trajectories. These messages are\n also the building blocks of most of the\n <a href=\"http://wiki.ros.org/control_msgs\">control_msgs</a> actions.")
    (license license:bsd-3)))

(define-public visualization-msgs
  (package
    (name "visualization-msgs")
    (version "1.12.7")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/common_msgs-release.git")
               (commit
                 "release/kinetic/visualization_msgs/1.12.7-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "13c8mmflnl6wgnpvvha6qb5x07v542imyg6cal4g3s29c95rjilq"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("message-generation" ,message-generation)))
    (inputs
     `(("cpp-common", cpp-common)
       ("roscpp-serialization" ,roscpp-serialization)
       ("message-runtime" ,message-runtime)))
    (propagated-inputs
      `(("geometry-msgs" ,geometry-msgs)
        ("std-msgs" ,std-msgs)))
    (home-page
      "http://ros.org/wiki/visualization_msgs")
    (synopsis
      "visualization_msgs is a set of messages used by higher level packages, such as <a href=\"/wiki/rviz\">rviz</a>, that deal in visualization-specific data.\n\n The main messages in visualization_msgs is <tt>visualization_msgs/Marker</tt>.\n The marker message is used to send visualization &quot;markers&quot; such as boxes, spheres, arrows, lines, etc. to a visualization environment such as <a href=\"http:///www.ros.org/wiki/rviz\">rviz</a>.\n See the rviz tutorial <a href=\"http://www.ros.org/wiki/rviz/Tutorials\">rviz tutorials</a> for more information.")
    (description
      "visualization_msgs is a set of messages used by higher level packages, such as <a href=\"/wiki/rviz\">rviz</a>, that deal in visualization-specific data.\n\n The main messages in visualization_msgs is <tt>visualization_msgs/Marker</tt>.\n The marker message is used to send visualization &quot;markers&quot; such as boxes, spheres, arrows, lines, etc. to a visualization environment such as <a href=\"http:///www.ros.org/wiki/rviz\">rviz</a>.\n See the rviz tutorial <a href=\"http://www.ros.org/wiki/rviz/Tutorials\">rviz tutorials</a> for more information.")
    (license license:bsd-3)))

(define-public orocos-kdl
  (package
    (name "orocos-kdl")
    (version "1.3.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/smits/orocos-kdl-release.git")
               (commit "release/kinetic/orocos_kdl/1.3.2-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1q5wjivb2x51mhd61wrjid4jqmjhwxz2mrjnc1r04hjawqpxkmxk"))))
    (build-system cmake-build-system)
    (arguments
     '(#:configure-flags '("-DENABLE_TESTS=ON") #:test-target "check"))
    (native-inputs `(("cppunit" ,cppunit)))
    (inputs `(("eigen" ,eigen)))
    (propagated-inputs
      `(("catkin" ,catkin)
        ("eigen" ,eigen)
        ("pkg-config" ,pkg-config)))
    (home-page "http://wiki.ros.org/orocos_kdl")
    (synopsis
      "This package contains a recent version of the Kinematics and Dynamics\n Library (KDL), distributed by the Orocos Project.")
    (description
      "This package contains a recent version of the Kinematics and Dynamics\n Library (KDL), distributed by the Orocos Project.")
    (license license:bsd-3)))

(define-public resource-retriever
  (package
    (name "resource-retriever")
    (version "1.12.6")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/resource_retriever-release.git")
               (commit
                 "release/kinetic/resource_retriever/1.12.6-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0acmczkmhcbihjn6zrc9s8p56yv48b61mzf7krbglvaaq0mysmbn"))))
    (build-system cmake-build-system)
    ;; TODO Run test, disable the http test.
    (arguments '(#:configure-flags '("-DCATKIN_ENABLE_TESTING=OFF") #:tests? #f))
    (native-inputs
      `(("catkin" ,catkin)
        ("boost:dev" ,boost "dev")))
    (inputs
      `(("boost" ,boost)
        ("curl" ,curl)
        ("roslib" ,roslib)
        ("rosconsole" ,rosconsole)))
    (propagated-inputs
      `(("python2-rospkg" ,python2-rospkg)
        ; ("python3-rospkg" ,python3-rospkg)
        ("curl" ,curl)
        ("rosconsole" ,rosconsole)))
    (home-page
      "http://ros.org/wiki/resource_retriever")
    (synopsis
      "This package retrieves data from url-format files such as http://,\n ftp://, package:// file://, etc., and loads the data into memory.\n The package:// url for ros packages is translated into a local\n file:// url. The resourse retriever was initially designed to load\n mesh files into memory, but it can be used for any type of\n data. The resource retriever is based on the the libcurl library.")
    (description
      "This package retrieves data from url-format files such as http://,\n ftp://, package:// file://, etc., and loads the data into memory.\n The package:// url for ros packages is translated into a local\n file:// url. The resourse retriever was initially designed to load\n mesh files into memory, but it can be used for any type of\n data. The resource retriever is based on the the libcurl library.")
    (license license:bsd-3)))

(define-public rosconsole-bridge
  (package
    (name "rosconsole-bridge")
    (version "0.5.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/rosconsole_bridge-release.git")
               (commit
                 "release/kinetic/rosconsole_bridge/0.5.2-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0y6j9w8p3gifq6jv5931d15gv3c12yfsaikncfrf628abp037sj8"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("console-bridge" ,console-bridge)
        ("rosconsole" ,rosconsole)))
    (propagated-inputs
      `(("console-bridge" ,console-bridge)
        ("rosconsole" ,rosconsole)))
    (home-page
      "http://www.ros.org/wiki/rosconsole_bridge")
    (synopsis
      "rosconsole_bridge is a package used in conjunction with console_bridge and rosconsole for connecting console_bridge-based logging to rosconsole-based logging.")
    (description
      "rosconsole_bridge is a package used in conjunction with console_bridge and rosconsole for connecting console_bridge-based logging to rosconsole-based logging.")
    (license license:bsd-3)))

(define-public pluginlib
  (package
    (name "pluginlib")
    (version "1.11.3")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/pluginlib-release.git")
               (commit "release/kinetic/pluginlib/1.11.3-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "02839189dai06kahccs1mrp38hmf5823irj7liknm67fgsn8zj33"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("boost:dev" ,boost "dev")))
    (inputs
      `(("cmake-modules" ,cmake-modules)
        ("boost" ,boost)
        ("class-loader" ,class-loader)
        ("rosconsole" ,rosconsole)
        ("roslib" ,roslib)
        ("tinyxml2" ,tinyxml2)))
    (home-page "http://www.ros.org/wiki/pluginlib")
    (synopsis
      "The pluginlib package provides tools for writing and dynamically loading plugins using the ROS build infrastructure.\n To work, these tools require plugin providers to register their plugins in the package.xml of their package.")
    (description
      "The pluginlib package provides tools for writing and dynamically loading plugins using the ROS build infrastructure.\n To work, these tools require plugin providers to register their plugins in the package.xml of their package.")
    (license license:bsd-3)))

(define-public class-loader
  (package
    (name "class-loader")
    (version "0.3.9")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/class_loader-release.git")
               (commit "release/kinetic/class_loader/0.3.9-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "13yfm2jhhksr27vzg62wyac6il20gjfb7dz2sxznl65pd2pjxi2q"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")))
    (inputs
     `(("boost" ,boost)
       ("cmake-modules" ,cmake-modules)
       ("console-bridge" ,console-bridge)
       ("poco" ,poco)))
    (home-page "http://ros.org/wiki/class_loader")
    (synopsis
      "The class_loader package is a ROS-independent package for loading plugins during runtime and the foundation of the higher level ROS &quot;pluginlib&quot; library. class_loader utilizes the host operating system's runtime loader to open runtime libraries (e.g. .so/.dll files), introspect the library for exported plugin classes, and allows users to instantiate objects of said exported classes without the explicit declaration (i.e. header file) for those classes.")
    (description
      "The class_loader package is a ROS-independent package for loading plugins during runtime and the foundation of the higher level ROS &quot;pluginlib&quot; library. class_loader utilizes the host operating system's runtime loader to open runtime libraries (e.g. .so/.dll files), introspect the library for exported plugin classes, and allows users to instantiate objects of said exported classes without the explicit declaration (i.e. header file) for those classes.")
    (license license:bsd-3)))

(define-public actionlib-msgs
  (package
    (name "actionlib-msgs")
    (version "1.12.7")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/common_msgs-release.git")
               (commit
                 "release/kinetic/actionlib_msgs/1.12.7-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0fh08fy08bz3cbp670r00jkdjw54rhdvjjwva8gkqi1syaxgzjjj"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("message-generation" ,message-generation)
       ("catkin" ,catkin)))
    (inputs
      `(("roscpp" ,roscpp)
        ("std-msgs" ,std-msgs)))
    (propagated-inputs
      `(("message-runtime" ,message-runtime)
        ("std-msgs" ,std-msgs)))
    (home-page "http://wiki.ros.org/actionlib_msgs")
    (synopsis
      "actionlib_msgs defines the common messages to interact with an\n action server and an action client. For full documentation of\n the actionlib API see\n the <a href=\"http://wiki.ros.org/actionlib\">actionlib</a>\n package.")
    (description
      "actionlib_msgs defines the common messages to interact with an\n action server and an action client. For full documentation of\n the actionlib API see\n the <a href=\"http://wiki.ros.org/actionlib\">actionlib</a>\n package.")
    (license license:bsd-3)))

(define-public object-recognition-msgs
  (package
    (name "object-recognition-msgs")
    (version "0.4.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/object_recognition_msgs-release.git")
               (commit
                 "release/kinetic/object_recognition_msgs/0.4.1-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0iadqp7bbpypvck0lj7chbyvgr7jw4rpsnyxx8hvk1s7047l5srg"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("message-generation" ,message-generation)))
    (inputs
      `(("cpp-common" ,cpp-common)
        ("roscpp-serialization" ,roscpp-serialization)
	("message-runtime" ,message-runtime)))
    (propagated-inputs
      `(("actionlib-msgs" ,actionlib-msgs)
        ("geometry-msgs" ,geometry-msgs)
        ("sensor-msgs" ,sensor-msgs)
        ("shape-msgs" ,shape-msgs)
        ("std-msgs" ,std-msgs)))
    (home-page
      "http://www.ros.org/wiki/object_recognition")
    (synopsis
      "Object_recognition_msgs contains the ROS message and the actionlib definition used in object_recognition_core")
    (description
      "Object_recognition_msgs contains the ROS message and the actionlib definition used in object_recognition_core")
    (license license:bsd-3)))

(define-public rosbag-migration-rule
  (package
    (name "rosbag-migration-rule")
    (version "1.0.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/rosbag_migration_rule-release.git")
               (commit
                 "release/kinetic/rosbag_migration_rule/1.0.0-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0w2db6jsz9x6xi5dfqzk4w946i5xrjqal78bbyswc645rv7nskbn"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (home-page
      "http://ros.org/wiki/rosbag_migration_rule")
    (synopsis
      "This empty package allows to export rosbag migration rule files without depending on rosbag.")
    (description
      "This empty package allows to export rosbag migration rule files without depending on rosbag.")
    (license license:bsd-3)))

(define-public tf
  (package
    (name "tf")
    (version "1.11.9")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/geometry-release.git")
               (commit "release/kinetic/tf/1.11.9-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0fc9jh9f2z00p4hqf13l0qsnq5a5pvby29liss9h03cx6kmyb22b"))))
    (build-system cmake-build-system)
    (arguments
     `(#:make-flags '("all" "tests")
       #:phases
       (modify-phases %standard-phases
		      (add-before 'check 'set-ros-home
				  (lambda _
				    (setenv "ROS_HOME" (getcwd))
				    #t)))))
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")
       ("googletest", googletest)
       ("message-generation" ,message-generation)
       ("python2-nose", python2-nose)
       ("rostest", rostest)))
    (inputs
     `(("actionlib" ,actionlib)
       ("angles" ,angles)
       ("boost" ,boost)
       ("message-filters" ,message-filters)
       ("message-runtime" ,message-runtime)
       ("rosconsole" ,rosconsole)
       ("roscpp" ,roscpp)
       ("rostime" ,rostime)
       ("sensor-msgs" ,sensor-msgs)))
    (propagated-inputs
     `(("geometry-msgs" ,geometry-msgs)
       ("graphviz" ,graphviz)
       ("rosconsole" ,rosconsole)
       ("roswtf" ,roswtf)
       ("sensor-msgs" ,sensor-msgs)
       ("std-msgs" ,std-msgs)
       ("tf2-ros" ,tf2-ros)))
    (home-page "http://www.ros.org/wiki/tf")
    (synopsis
      "tf is a package that lets the user keep track of multiple coordinate\nframes over time. tf maintains the relationship between coordinate\nframes in a tree structure buffered in time, and lets the user\ntransform points, vectors, etc between any two coordinate frames at\nany desired point in time.\n\n <p><b>Migration</b>: Since ROS Hydro, tf has been &quot;deprecated&quot; in favor of <a href=\"http://wiki.ros.org/tf2\">tf2</a>. tf2 is an iteration on tf providing generally the same feature set more efficiently. As well as adding a few new features.<br/>\n As tf2 is a major change the tf API has been maintained in its current form. Since tf2 has a superset of the tf features with a subset of the dependencies the tf implementation has been removed and replaced with calls to tf2 under the hood. This will mean that all users will be compatible with tf2. It is recommended for new work to use tf2 directly as it has a cleaner interface. However tf will continue to be supported for through at least J Turtle.\n </p>")
    (description
      "tf is a package that lets the user keep track of multiple coordinate\nframes over time. tf maintains the relationship between coordinate\nframes in a tree structure buffered in time, and lets the user\ntransform points, vectors, etc between any two coordinate frames at\nany desired point in time.\n\n <p><b>Migration</b>: Since ROS Hydro, tf has been &quot;deprecated&quot; in favor of <a href=\"http://wiki.ros.org/tf2\">tf2</a>. tf2 is an iteration on tf providing generally the same feature set more efficiently. As well as adding a few new features.<br/>\n As tf2 is a major change the tf API has been maintained in its current form. Since tf2 has a superset of the tf features with a subset of the dependencies the tf implementation has been removed and replaced with calls to tf2 under the hood. This will mean that all users will be compatible with tf2. It is recommended for new work to use tf2 directly as it has a cleaner interface. However tf will continue to be supported for through at least J Turtle.\n </p>")
    (license license:bsd-3)))

(define-public tf2-msgs
  (package
    (name "tf2-msgs")
    (version "0.5.20")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/geometry2-release.git")
               (commit "release/kinetic/tf2_msgs/0.5.20-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "03nvg4m557q950v1hn6wbczhx1cdy2nv9l7xvp41n7cfg2a7ngvv"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("boost:dev" ,boost "dev")
       ("catkin" ,catkin)
       ("message-generation" ,message-generation)))
    (inputs
     `(("boost" ,boost)
       ("cpp-common" ,cpp-common)
       ("roscpp-serialization" ,roscpp-serialization)
       ("message-runtime" ,message-runtime)))
    (propagated-inputs
     `(("actionlib-msgs" ,actionlib-msgs)
       ("geometry-msgs" ,geometry-msgs)))
    (home-page "http://www.ros.org/wiki/tf2_msgs")
    (synopsis "tf2_msgs")
    (description "tf2_msgs")
    (license license:bsd-3)))

(define-public tf2
  (package
    (name "tf2")
    (version "0.5.20")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/geometry2-release.git")
               (commit "release/kinetic/tf2/0.5.20-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1gjhhr77l0cms1qlz9valyf1znwhixygyxxydi3sr21l9hccgjjk"))))
    (build-system cmake-build-system)
    (arguments
     `(#:make-flags '("all" "tests")
       #:phases
       (modify-phases %standard-phases
       (add-before 'check 'set-ros-home
	 (lambda _
	   (setenv "ROS_HOME" (getcwd)))))))
    (native-inputs
     `(("boost:dev" ,boost "dev")
       ("catkin" ,catkin)
       ("googletest" ,googletest)
       ("message-generation" ,message-generation)
       ("python2-nose" ,python2-nose)))
    (inputs
     `(("boost" ,boost)
       ("cpp-common" ,cpp-common)
       ("roscpp" ,roscpp)
       ("roscpp-serialization" ,roscpp-serialization)
       ("console-bridge" ,console-bridge)
       ("rostime" ,rostime)))
    (propagated-inputs
     `(("console-bridge" ,console-bridge)
       ("geometry-msgs" ,geometry-msgs)
       ("rostime" ,rostime)
       ("tf2-msgs" ,tf2-msgs)))
    (home-page "http://www.ros.org/wiki/tf2")
    (synopsis
      "tf2 is the second generation of the transform library, which lets\n the user keep track of multiple coordinate frames over time. tf2\n maintains the relationship between coordinate frames in a tree\n structure buffered in time, and lets the user transform points,\n vectors, etc between any two coordinate frames at any desired\n point in time.")
    (description
      "tf2 is the second generation of the transform library, which lets\n the user keep track of multiple coordinate frames over time. tf2\n maintains the relationship between coordinate frames in a tree\n structure buffered in time, and lets the user transform points,\n vectors, etc between any two coordinate frames at any desired\n point in time.")
    (license license:bsd-3)))

(define-public angles
  (package
    (name "angles")
    (version "1.9.12")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/geometry_angles_utils-release.git")
               (commit "release/kinetic/angles/1.9.12-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1pgn9kj655c1srpg33nrdvnc5yfshpzfw4zzdjg7jx39anrya7yi"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (home-page "http://wiki.ros.org/angles")
    (synopsis
      "This package provides a set of simple math utilities to work\n with angles. The utilities cover simple things like\n normalizing an angle and conversion between degrees and\n radians. But even if you're trying to calculate things like\n the shortest angular distance between two joint space\n positions of your robot, but the joint motion is constrained\n by joint limits, this package is what you need. The code in\n this package is stable and well tested. There are no plans for\n major changes in the near future.")
    (description
      "This package provides a set of simple math utilities to work\n with angles. The utilities cover simple things like\n normalizing an angle and conversion between degrees and\n radians. But even if you're trying to calculate things like\n the shortest angular distance between two joint space\n positions of your robot, but the joint motion is constrained\n by joint limits, this package is what you need. The code in\n this package is stable and well tested. There are no plans for\n major changes in the near future.")
    (license license:bsd-3)))

(define-public message-filters
  (package
    (name "message-filters")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit
                 "release/kinetic/message_filters/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1zzdjx162dc79w2zh5l5pmg5s6yynzsg5x64gcf8ywr6gk5b7hr5"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")))
    (inputs
     `(("boost" ,boost)
       ("rosconsole" ,rosconsole)
       ("roscpp" ,roscpp)
       ("rostest" ,rostest)
       ("rosunit" ,rosunit)
       ("xmlrpcpp" ,xmlrpcpp)))
    (home-page "http://ros.org/wiki/message_filters")
    (synopsis
      "A set of message filters which take in messages and may output those messages at a later time, based on the conditions that filter needs met.")
    (description
      "A set of message filters which take in messages and may output those messages at a later time, based on the conditions that filter needs met.")
    (license license:bsd-3)))

(define-public tf2-ros
  (package
    (name "tf2-ros")
    (version "0.5.20")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/geometry2-release.git")
               (commit "release/kinetic/tf2_ros/0.5.20-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0z328zc2dw3j6kimivvnb3y2jv4nnnc0dp0mvby35zrgknyc1n89"))))
    (build-system cmake-build-system)
    (arguments
     `(#:make-flags '("all" "tests")
       #:phases
       (modify-phases %standard-phases
		      (add-before 'check 'set-ros-home
				  (lambda _
				    (setenv "ROS_HOME" (getcwd))
				    #t)))))
    (native-inputs
     `(("boost:dev" ,boost "dev")
       ("catkin" ,catkin)
       ("googletest" ,googletest)
       ("python2-nose" ,python2-nose)
       ("rostest", rostest)))
    (inputs
     `(("actionlib" ,actionlib)
       ("boost" ,boost)
       ("geometry-msgs" ,geometry-msgs)
       ("message-filters" ,message-filters)
       ("roscpp" ,roscpp)
       ("rosgraph" ,rosgraph)
       ("rospy" ,rospy)
       ("std-msgs" ,std-msgs)
       ("tf2" ,tf2)
       ("tf2-msgs" ,tf2-msgs)
       ("tf2-py" ,tf2-py)
       ("xmlrpcpp" ,xmlrpcpp)))
    (propagated-inputs
     `(("actionlib-msgs" ,actionlib-msgs)
       ("geometry-msgs" ,geometry-msgs)
       ("rosgraph" ,rosgraph)
       ("rospy" ,rospy)
       ("std-msgs" ,std-msgs)
       ("tf2-msgs" ,tf2-msgs)
       ("tf2-py" ,tf2-py)
       ("xmlrpcpp" ,xmlrpcpp)))
    (home-page "http://www.ros.org/wiki/tf2_ros")
    (synopsis
      "This package contains the ROS bindings for the tf2 library, for both Python and C++.")
    (description
      "This package contains the ROS bindings for the tf2 library, for both Python and C++.")
    (license license:bsd-3)))

(define-public roswtf
  (package
    (name "roswtf")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/roswtf/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0yvrscsb4v4xmdlh5yydmdxqi8f51080pcgks7rz0k5g1yy1kh1q"))))
    (build-system cmake-build-system)
    (arguments
     ;; Relies on rospy/talker.py
     `(#:tests? #f))
    (native-inputs
     `(("catkin" ,catkin)
       ("googletest" ,googletest)
       ("python2-nose" ,python2-nose)
       ("roslang" ,roslang)
       ("rostest" ,rostest)))
    (inputs
     `(("rosbuild" ,rosbuild)
       ("roslib" ,roslib)))
    (propagated-inputs
      `(("python2-paramiko" ,python2-paramiko)
        ("python2-rospkg" ,python2-rospkg)
        ("rosgraph" ,rosgraph)
        ("roslaunch" ,roslaunch)
        ("rosnode" ,rosnode)
        ("rosservice" ,rosservice)))
    (home-page "http://ros.org/wiki/roswtf")
    (synopsis
      "roswtf is a tool for diagnosing issues with a running ROS system. Think of it as a FAQ implemented in code.")
    (description
      "roswtf is a tool for diagnosing issues with a running ROS system. Think of it as a FAQ implemented in code.")
    (license license:bsd-3)))

(define-public rostest
  (package
    (name "rostest")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rostest/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1bfhxf09pslq364nl4kd0g1mfa7hni0r8h6pkn2m6jh5vd89wz7c"))))
    (build-system cmake-build-system)
    ;; rostest search for a talker.py in the rospy package, which doesn't exists.
    (arguments `(#:tests? #f))
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")))
    (inputs `(("boost" ,boost) ("rosunit" ,rosunit)))
    (propagated-inputs
      `(("rosgraph" ,rosgraph)
        ("roslaunch" ,roslaunch)
        ("rosmaster" ,rosmaster)
        ("rospy" ,rospy)
        ("rosunit" ,rosunit)))
    (home-page "http://ros.org/wiki/rostest")
    (synopsis
      "Integration test suite based on roslaunch that is compatible with xUnit frameworks.")
    (description
      "Integration test suite based on roslaunch that is compatible with xUnit frameworks.")
    (license license:bsd-3)))

(define-public rosgraph
  (package
    (name "rosgraph")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rosgraph/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1xpmlbdwg0qc5p285xlb0h0h1ajyd5h4ddq91wijpczz5y8dwdm4"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("python2-netifaces" ,python2-netifaces)
        ("python2-rospkg" ,python2-rospkg)))
    (home-page "http://ros.org/wiki/rosgraph")
    (synopsis
      "rosgraph contains the rosgraph command-line tool, which prints\n information about the ROS Computation Graph. It also provides an\n internal library that can be used by graphical tools.")
    (description
      "rosgraph contains the rosgraph command-line tool, which prints\n information about the ROS Computation Graph. It also provides an\n internal library that can be used by graphical tools.")
    (license license:bsd-3)))

(define-public roslaunch
  (package
    (name "roslaunch")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/roslaunch/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1s161h1jdqk9gq8l9w7n9fn1mk44sbzf0r8diq0bymphp54myf78"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("python2-paramiko" ,python2-paramiko)
        ("python2-rospkg" ,python2-rospkg)
        ("python2-pyyaml" ,python2-pyyaml)
        ("rosclean" ,rosclean)
        ("rosgraph-msgs" ,rosgraph-msgs)
        ("roslib" ,roslib)
        ("rosmaster" ,rosmaster)
        ("rosout" ,rosout)
        ("rosparam" ,rosparam)
        ("rosunit" ,rosunit)))
    (home-page "http://ros.org/wiki/roslaunch")
    (synopsis
      "roslaunch is a tool for easily launching multiple ROS <a href=\"http://ros.org/wiki/Nodes\">nodes</a> locally and remotely\n via SSH, as well as setting parameters on the <a href=\"http://ros.org/wiki/Parameter Server\">Parameter\n Server</a>. It includes options to automatically respawn processes\n that have already died. roslaunch takes in one or more XML\n configuration files (with the <tt>.launch</tt> extension) that\n specify the parameters to set and nodes to launch, as well as the\n machines that they should be run on.")
    (description
      "roslaunch is a tool for easily launching multiple ROS <a href=\"http://ros.org/wiki/Nodes\">nodes</a> locally and remotely\n via SSH, as well as setting parameters on the <a href=\"http://ros.org/wiki/Parameter Server\">Parameter\n Server</a>. It includes options to automatically respawn processes\n that have already died. roslaunch takes in one or more XML\n configuration files (with the <tt>.launch</tt> extension) that\n specify the parameters to set and nodes to launch, as well as the\n machines that they should be run on.")
    (license license:bsd-3)))

(define-public rosmaster
  (package
    (name "rosmaster")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rosmaster/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "18gqx7r1531zvhybm5rha5jcl7jck16p2yrrgxih40w5byx8zwmn"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("rosgraph" ,rosgraph)
        ("python2-defusedxml" ,python2-defusedxml)))
    (home-page "http://ros.org/wiki/rosmaster")
    (synopsis
      "ROS <a href=\"http://ros.org/wiki/Master\">Master</a> implementation.")
    (description
      "ROS <a href=\"http://ros.org/wiki/Master\">Master</a> implementation.")
    (license license:bsd-3)))

(define-public rospy
  (package
    (name "rospy")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rospy/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "19pzq3cz3gsdnfdl4phwzr109w3lcikxn53yyj4n0dc38rsg823g"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("genpy" ,genpy)
        ("python2-numpy" ,python2-numpy)
        ("python2-rospkg" ,python2-rospkg)
        ("python2-pyyaml" ,python2-pyyaml)
        ("roscpp" ,roscpp)
        ("rosgraph" ,rosgraph)
        ("rosgraph-msgs" ,rosgraph-msgs)
        ("roslib" ,roslib)
        ("std-msgs" ,std-msgs)))
    (home-page "http://ros.org/wiki/rospy")
    (synopsis
      "rospy is a pure Python client library for ROS. The rospy client\n API enables Python programmers to quickly interface with ROS <a href=\"http://ros.org/wiki/Topics\">Topics</a>, <a href=\"http://ros.org/wiki/Services\">Services</a>, and <a href=\"http://ros.org/wiki/Parameter Server\">Parameters</a>. The\n design of rospy favors implementation speed (i.e. developer\n time) over runtime performance so that algorithms can be quickly\n prototyped and tested within ROS. It is also ideal for\n non-critical-path code, such as configuration and initialization\n code. Many of the ROS tools are written in rospy to take\n advantage of the type introspection capabilities.\n\n Many of the ROS tools, such\n as <a href=\"http://ros.org/wiki/rostopic\">rostopic</a>\n and <a href=\"http://ros.org/wiki/rosservice\">rosservice</a>, are\n built on top of rospy.")
    (description
      "rospy is a pure Python client library for ROS. The rospy client\n API enables Python programmers to quickly interface with ROS <a href=\"http://ros.org/wiki/Topics\">Topics</a>, <a href=\"http://ros.org/wiki/Services\">Services</a>, and <a href=\"http://ros.org/wiki/Parameter Server\">Parameters</a>. The\n design of rospy favors implementation speed (i.e. developer\n time) over runtime performance so that algorithms can be quickly\n prototyped and tested within ROS. It is also ideal for\n non-critical-path code, such as configuration and initialization\n code. Many of the ROS tools are written in rospy to take\n advantage of the type introspection capabilities.\n\n Many of the ROS tools, such\n as <a href=\"http://ros.org/wiki/rostopic\">rostopic</a>\n and <a href=\"http://ros.org/wiki/rosservice\">rosservice</a>, are\n built on top of rospy.")
    (license license:bsd-3)))

(define-public rosnode
  (package
    (name "rosnode")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rosnode/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1pmqgzy0jj88nz6d7q2vpf0hk0pb2q179bgq8azch1ivm8bjm61k"))))
    (build-system cmake-build-system)
    ;; Depends on rospy/talker.py
    (arguments `(#:tests? #f))
    (native-inputs
     `(("catkin" ,catkin)
       ("googletest" ,googletest)
       ("python2-nose" ,python2-nose)
       ("rostest" ,rostest)))
    (inputs
     `())
    (propagated-inputs
     `(("rosgraph" ,rosgraph)
       ("rostopic" ,rostopic)))
    (home-page "http://ros.org/wiki/rosnode")
    (synopsis
      "rosnode is a command-line tool for displaying debug information\n about ROS <a href=\"http://www.ros.org/wiki/Nodes\">Nodes</a>,\n including publications, subscriptions and connections. It also\n contains an experimental library for retrieving node\n information. This library is intended for internal use only.")
    (description
      "rosnode is a command-line tool for displaying debug information\n about ROS <a href=\"http://www.ros.org/wiki/Nodes\">Nodes</a>,\n including publications, subscriptions and connections. It also\n contains an experimental library for retrieving node\n information. This library is intended for internal use only.")
    (license license:bsd-3)))

(define-public rosclean
  (package
    (name "rosclean")
    (version "1.14.6")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros-release.git")
               (commit "release/kinetic/rosclean/1.14.6-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1xpmca1a66dwznja4syc639akhmnnjj1g7hzmshqi61vw0yws9gw"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("python2-rospkg" ,python2-rospkg)))
    (home-page "http://ros.org/wiki/rosclean")
    (synopsis
      "rosclean: cleanup filesystem resources (e.g. log files).")
    (description
      "rosclean: cleanup filesystem resources (e.g. log files).")
    (license license:bsd-3)))

(define-public rosmsg
  (package
    (name "rosmsg")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rosmsg/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1bjg96zzssrxplw2l5h49rb37h339alwfhr8mfzxh99hpcpwfygr"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("catkin" ,catkin)
        ("genmsg" ,genmsg)
        ("genpy" ,genpy)
        ("python2-rospkg" ,python2-rospkg)
        ("rosbag" ,rosbag)
        ("roslib" ,roslib)))
    (home-page "http://ros.org/wiki/rosmsg")
    (synopsis
      "rosmsg contains two command-line tools: <tt>rosmsg</tt> and\n <tt>rossrv</tt>. <tt>rosmsg</tt> is a command-line tool for\n displaying information about <a href=\"http://www.ros.org/wiki/msg\">ROS Message\n types</a>. <tt>rossrv</tt> is a command-line tool for displaying\n information about <a href=\"http://www.ros.org/wiki/srv\">ROS\n Service types</a>.")
    (description
      "rosmsg contains two command-line tools: <tt>rosmsg</tt> and\n <tt>rossrv</tt>. <tt>rosmsg</tt> is a command-line tool for\n displaying information about <a href=\"http://www.ros.org/wiki/msg\">ROS Message\n types</a>. <tt>rossrv</tt> is a command-line tool for displaying\n information about <a href=\"http://www.ros.org/wiki/srv\">ROS\n Service types</a>.")
    (license license:bsd-3)))

(define-public rosservice
  (package
    (name "rosservice")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rosservice/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0n339cakpmdrjr4k2lhspxk9khy405pga800r6qzpzgl84i1g4g6"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("genpy" ,genpy)
        ("rosgraph" ,rosgraph)
        ("roslib" ,roslib)
        ("rospy" ,rospy)
        ("rosmsg" ,rosmsg)))
    (home-page "http://ros.org/wiki/rosservice")
    (synopsis
      "rosservice contains the rosservice command-line tool for listing\n and querying ROS <a href=\"http://www.ros.org/wiki/Services\">Services</a>. It also\n contains a Python library for retrieving information about\n Services and dynamically invoking them. The Python library is\n experimental and is for internal-use only.")
    (description
      "rosservice contains the rosservice command-line tool for listing\n and querying ROS <a href=\"http://www.ros.org/wiki/Services\">Services</a>. It also\n contains a Python library for retrieving information about\n Services and dynamically invoking them. The Python library is\n experimental and is for internal-use only.")
    (license license:bsd-3)))

(define-public rosout
  (package
    (name "rosout")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rosout/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "03cz52q9gwcvb245lbxz4z7h24cgl6g0a0c2kfw693cqr6dmgwhw"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("roscpp" ,roscpp)
        ("rosgraph-msgs" ,rosgraph-msgs)))
    (propagated-inputs
      `(("roscpp" ,roscpp)
        ("rosgraph-msgs" ,rosgraph-msgs)))
    (home-page "http://ros.org/wiki/rosout")
    (synopsis
      "System-wide logging mechanism for messages sent to the /rosout topic.")
    (description
      "System-wide logging mechanism for messages sent to the /rosout topic.")
    (license license:bsd-3)))

(define-public rosparam
  (package
    (name "rosparam")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rosparam/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "14lg2nf4k4ypp0i9fzdxzjnjvshfc5malv83hfbzrjh60phgbd94"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("python2-pyyaml" ,python2-pyyaml)
        ("rosgraph" ,rosgraph)))
    (home-page "http://ros.org/wiki/rosparam")
    (synopsis
      "rosparam contains the rosparam command-line tool for getting and\n setting ROS Parameters on the <a href=\"http://www.ros.org/wiki/Parameter%20Server\">Parameter\n Server</a> using YAML-encoded files. It also contains an\n experimental library for using YAML with the Parameter\n Server. This library is intended for internal use only.\n\n rosparam can be invoked within a <a href=\"http://www.ros.org/wiki/roslaunch\">roslaunch</a> file.")
    (description
      "rosparam contains the rosparam command-line tool for getting and\n setting ROS Parameters on the <a href=\"http://www.ros.org/wiki/Parameter%20Server\">Parameter\n Server</a> using YAML-encoded files. It also contains an\n experimental library for using YAML with the Parameter\n Server. This library is intended for internal use only.\n\n rosparam can be invoked within a <a href=\"http://www.ros.org/wiki/roslaunch\">roslaunch</a> file.")
    (license license:bsd-3)))

(define-public actionlib
  (package
    (name "actionlib")
    (version "1.11.13")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/actionlib-release.git")
               (commit "release/kinetic/actionlib/1.11.13-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
	   "1n5v75f07k1g8ps4b821jp38l32gx2w7mizn7cw7yjg0552aw6wf"))
	(patches
	 (search-patches
	  ;; For some reason, we need a sleep to make the test pass all the times.
	  ;; FIXME: Assert this is not a bug.
	  "ros/kinetic/patches/actionlib-fix-test.patch"))))
    (build-system cmake-build-system)
    (arguments
     `(#:make-flags '("all" "tests")
       #:phases
       (modify-phases %standard-phases
       (add-before 'check 'set-ros-home
		   (lambda _
		     (setenv "ROS_HOME" (getcwd))
		     #t)))))
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")
       ("googletest" ,googletest)
       ("message-generation" ,message-generation)
       ("python2-nose" ,python2-nose)
       ("rosnode" ,rosnode)
       ("rostest" ,rostest)
       ("rostopic" ,rostopic)))
    (inputs
     `(("boost" ,boost)
       ("message-runtime" ,message-runtime)
       ("roscpp" ,roscpp)
       ("roslib" ,roslib)
       ("rospy" ,rospy)))
    (propagated-inputs
     `(("actionlib-msgs" ,actionlib-msgs)
       ("python2-wxpython" ,python2-wxpython)
       ("std-msgs" ,std-msgs)))
    (home-page "http://www.ros.org/wiki/actionlib")
    (synopsis
      "The actionlib stack provides a standardized interface for\n interfacing with preemptable tasks. Examples of this include moving\n the base to a target location, performing a laser scan and returning\n the resulting point cloud, detecting the handle of a door, etc.")
    (description
      "The actionlib stack provides a standardized interface for\n interfacing with preemptable tasks. Examples of this include moving\n the base to a target location, performing a laser scan and returning\n the resulting point cloud, detecting the handle of a door, etc.")
    (license license:bsd-3)))

(define-public tf2-py
  (package
    (name "tf2-py")
    (version "0.5.20")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/geometry2-release.git")
               (commit "release/kinetic/tf2_py/0.5.20-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0pvfx2xb1mc4c6k1ph1pbasqllm4n1cz658f3i4zspm71s4v3cfx"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs `(("tf2" ,tf2) ("rospy" ,rospy)))
    (propagated-inputs
      `(("tf2" ,tf2) ("rospy" ,rospy)))
    (home-page "http://ros.org/wiki/tf2_py")
    (synopsis "The tf2_py package")
    (description "The tf2_py package")
    (license license:bsd-3)))

(define-public rostopic
  (package
    (name "rostopic")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rostopic/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0zf06v7ffk7nrz84hgggf313da56byykk6xih25q93k9wvjlvrdz"))))
    (build-system cmake-build-system)
    (arguments
     ;; Tests relies on rospy/talker.py, which doesn't exists???
     `(#:tests? #f))
    (native-inputs
     `(("catkin" ,catkin)
       ("googletest" ,googletest-1.8)
       ("python2-nose" ,python2-nose)
       ("rostest" ,rostest)))
    (inputs
     `(("genpy" ,genpy)
       ;; Rosbag include topic-tools, which include rostopic...
       ("rosbag" ,rosbag)
       ("rospy" ,rospy)))
    (home-page "http://ros.org/wiki/rostopic")
    (synopsis
      "rostopic contains the rostopic command-line tool for displaying\n debug information about\n ROS <a href=\"http://www.ros.org/wiki/Topics\">Topics</a>, including\n publishers, subscribers, publishing rate,\n and ROS <a href=\"http://www.ros.org/wiki/Messages\">Messages</a>. It also\n contains an experimental Python library for getting information about\n and interacting with topics dynamically. This library is for\n internal-use only as the code API may change, though it does provide\n examples of how to implement dynamic subscription and publication\n behaviors in ROS.")
    (description
      "rostopic contains the rostopic command-line tool for displaying\n debug information about\n ROS <a href=\"http://www.ros.org/wiki/Topics\">Topics</a>, including\n publishers, subscribers, publishing rate,\n and ROS <a href=\"http://www.ros.org/wiki/Messages\">Messages</a>. It also\n contains an experimental Python library for getting information about\n and interacting with topics dynamically. This library is for\n internal-use only as the code API may change, though it does provide\n examples of how to implement dynamic subscription and publication\n behaviors in ROS.")
    (license license:bsd-3)))

(define-public rosbag
  (package
    (name "rosbag")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/rosbag/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0sxd4d49nnyq4741wzq4d6qk7kwgkzwf6vbpykwaybmb5fysjk5y"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")))
    (inputs
     `(("boost" ,boost)
       ("cpp-common" ,cpp-common)
       ("python2-pillow" ,python2-pillow)
       ("rosbag-storage" ,rosbag-storage)
       ("rosconsole" ,rosconsole)
       ("roscpp" ,roscpp)
       ("roscpp-serialization" ,roscpp-serialization)
       ("std-srvs" ,std-srvs)
       ("topic-tools" ,topic-tools)
       ("xmlrpcpp" ,xmlrpcpp)))
    (propagated-inputs
     `(("python2-rospkg" ,python2-rospkg)
       ("rosbag-storage" ,rosbag-storage)
       ("rosconsole" ,rosconsole)
       ("rospy" ,rospy)
       ("std-srvs" ,std-srvs)
       ("topic-tools" ,topic-tools)))
    (home-page "http://ros.org/wiki/rosbag")
    (synopsis
      "This is a set of tools for recording from and playing back to ROS\n topics. It is intended to be high performance and avoids\n deserialization and reserialization of the messages.")
    (description
      "This is a set of tools for recording from and playing back to ROS\n topics. It is intended to be high performance and avoids\n deserialization and reserialization of the messages.")
    (license license:bsd-3)))

(define-public rosbag-storage
  (package
    (name "rosbag-storage")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit
                 "release/kinetic/rosbag_storage/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1q79a97s5l7xasx1p96sr47qh2praidl497slgjq6mgln9alpr1c"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")))
    (inputs
      `(("boost" ,boost)
        ("bzip2" ,bzip2)
        ("cpp-common" ,cpp-common)
        ("console-bridge" ,console-bridge)
        ("roscpp-serialization" ,roscpp-serialization)
        ("roscpp-traits" ,roscpp-traits)
        ("rostime" ,rostime)
        ("roslz4" ,roslz4)))
    (propagated-inputs
      `(("bzip2" ,bzip2)
        ("cpp-common" ,cpp-common)
        ("console-bridge" ,console-bridge)
        ("roscpp-serialization" ,roscpp-serialization)
        ("roscpp-traits" ,roscpp-traits)
        ("rostime" ,rostime)
        ("roslz4" ,roslz4)))
    (home-page "http://wiki.ros.org")
    (synopsis
      "This is a set of tools for recording from and playing back ROS\n message without relying on the ROS client library.")
    (description
      "This is a set of tools for recording from and playing back ROS\n message without relying on the ROS client library.")
    (license license:bsd-3)))

(define-public std-srvs
  (package
    (name "std-srvs")
    (version "1.11.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm_msgs-release.git")
               (commit "release/kinetic/std_srvs/1.11.2-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1lrc01bxlh4arcjaxa1vlzvhvcp5xd4ia0g01pbblmmhvyfy06s7"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("message-generation" ,message-generation)))
    (propagated-inputs
      `(("message-runtime" ,message-runtime)))
    (home-page "http://ros.org/wiki/std_srvs")
    (synopsis "Common service definitions.")
    (description "Common service definitions.")
    (license license:bsd-3)))

(define-public topic-tools
  (package
    (name "topic-tools")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/topic_tools/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0xrdsvpcvjq2h6zqapdsf2p4wm5lqdri3yzgldppzynxsywmpzky"))))
    (build-system cmake-build-system)
    (arguments
     `(#:tests? #f))
    (native-inputs
     `(("catkin" ,catkin)
       ("message-generation" ,message-generation)
       ("googletest" ,googletest-1.8)
       ("python2-nose" ,python2-nose)
       ("rostest" ,rostest)
       ;; Needed for tests, but normally it includes this package, so there is a recursive dependency...
       ; ("rostopic" ,rostopic)
       ("rosunit" ,rosunit)))
    (inputs
     `(("cpp-common" ,cpp-common)
       ("message-runtime" ,message-runtime)
       ("rosconsole" ,rosconsole)
       ("roscpp" ,roscpp)
       ("rostime" ,rostime)
       ("xmlrpcpp" ,xmlrpcpp)))
    (propagated-inputs
     `(("rosconsole" ,rosconsole)
       ("std-msgs" ,std-msgs)))
    (home-page "http://ros.org/wiki/topic_tools")
    (synopsis
      "Tools for directing, throttling, selecting, and otherwise messing with\n ROS topics at a meta level. None of the programs in this package actually\n know about the topics whose streams they are altering; instead, these\n tools deal with messages as generic binary blobs. This means they can be\n applied to any ROS topic.")
    (description
      "Tools for directing, throttling, selecting, and otherwise messing with\n ROS topics at a meta level. None of the programs in this package actually\n know about the topics whose streams they are altering; instead, these\n tools deal with messages as generic binary blobs. This means they can be\n applied to any ROS topic.")
    (license license:bsd-3)))

(define-public roslz4
  (package
    (name "roslz4")
    (version "1.12.14")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_comm-release.git")
               (commit "release/kinetic/roslz4/1.12.14-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0xs9px4rp2056cjqzwaizy280p808hv7fdkc9ya4b0cs9i082fyy"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs `(("lz4" ,lz4)))
    (propagated-inputs `(("lz4" ,lz4)))
    (home-page "http://wiki.ros.org")
    (synopsis
      "A Python and C++ implementation of the LZ4 streaming format. Large data\n streams are split into blocks which are compressed using the very fast LZ4\n compression algorithm.")
    (description
      "A Python and C++ implementation of the LZ4 streaming format. Large data\n streams are split into blocks which are compressed using the very fast LZ4\n compression algorithm.")
    (license license:bsd-3)))

(define-public dynamic-reconfigure
  (package
    (name "dynamic-reconfigure")
    (version "1.5.50")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/dynamic_reconfigure-release.git")
               (commit
                 "release/kinetic/dynamic_reconfigure/1.5.50-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "04d86vfhk675scm5wk8ydcxfb89grlf0nifnm1blcnnxzq7mbr9l"))))
    (build-system cmake-build-system)
    (arguments
     `(#:make-flags '("all" "tests")
       #:phases
       (modify-phases %standard-phases
		      (add-before 'check 'set-ros-home
				  (lambda _
				    (setenv "ROS_HOME" (getcwd))
				    #t)))))
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")
       ("googletest" ,googletest-1.8)
       ("message-generation" ,message-generation)
       ("rostest" ,rostest)))
    (inputs
     `(("boost" ,boost)
       ("message-runtime" ,message-runtime)
       ("roscpp-serialization" ,roscpp-serialization)
       ("roslib" ,roslib)
       ("roscpp" ,roscpp)
       ("std-msgs" ,std-msgs)))
    (propagated-inputs
     `(("rospy" ,rospy)
       ("rosservice" ,rosservice)
       ("std-msgs" ,std-msgs)))
    (home-page
      "http://ros.org/wiki/dynamic_reconfigure")
    (synopsis
      "This unary stack contains the dynamic_reconfigure package which provides a means to change\n node parameters at any time without having to restart the node.")
    (description
      "This unary stack contains the dynamic_reconfigure package which provides a means to change\n node parameters at any time without having to restart the node.")
    (license license:bsd-3)))

(define-public tf-conversions
  (package
    (name "tf-conversions")
    (version "1.11.9")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/geometry-release.git")
               (commit
                 "release/kinetic/tf_conversions/1.11.9-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1pzibvf8vkkgga69hxbp0yl3ms1sgycgp5xc8d272l52lcph4m1f"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("cmake-modules" ,cmake-modules)
        ("eigen" ,eigen)
        ("geometry-msgs" ,geometry-msgs)
        ("kdl-conversions" ,kdl-conversions)
        ("orocos-kdl" ,orocos-kdl)
        ("tf" ,tf)))
    (propagated-inputs
      `(("eigen" ,eigen)
        ("geometry-msgs" ,geometry-msgs)
        ("kdl-conversions" ,kdl-conversions)
        ("orocos-kdl" ,orocos-kdl)
        ("python2-orocos-kdl" ,python2-orocos-kdl)
        ("tf" ,tf)))
    (home-page
      "http://www.ros.org/wiki/tf_conversions")
    (synopsis
      "This package contains a set of conversion functions to convert\ncommon tf datatypes (point, vector, pose, etc) into semantically\nidentical datatypes used by other libraries. The conversion functions\nmake it easier for users of the transform library (tf) to work with\nthe datatype of their choice. Currently this package has support for\nthe Kinematics and Dynamics Library (KDL) and the Eigen matrix\nlibrary. This package is stable, and will get integrated into tf in\nthe next major release cycle (see roadmap).")
    (description
      "This package contains a set of conversion functions to convert\ncommon tf datatypes (point, vector, pose, etc) into semantically\nidentical datatypes used by other libraries. The conversion functions\nmake it easier for users of the transform library (tf) to work with\nthe datatype of their choice. Currently this package has support for\nthe Kinematics and Dynamics Library (KDL) and the Eigen matrix\nlibrary. This package is stable, and will get integrated into tf in\nthe next major release cycle (see roadmap).")
    (license license:bsd-3)))

(define-public image-transport
  (package
    (name "image-transport")
    (version "1.11.13")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/image_common-release.git")
               (commit
                 "release/kinetic/image_transport/1.11.13-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "09f998cacs3z958kn1vna1ma0vqfl3wbyzygq8kqx61x1wz9mfhm"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("boost:dev" ,boost "dev")
       ("catkin" ,catkin)))
    (inputs
     `(("boost" ,boost)
       ("class-loader" ,class-loader)
       ("message-filters" ,message-filters)
       ("pluginlib" ,pluginlib)
       ("rosconsole" ,rosconsole)
       ("roscpp" ,roscpp)
       ("roslib" ,roslib)))
    (propagated-inputs
     `(("sensor-msgs" ,sensor-msgs)))
    (home-page "http://ros.org/wiki/image_transport")
    (synopsis
      "image_transport should always be used to subscribe to and publish images. It provides transparent\n support for transporting images in low-bandwidth compressed formats. Examples (provided by separate\n plugin packages) include JPEG/PNG compression and Theora streaming video.")
    (description
      "image_transport should always be used to subscribe to and publish images. It provides transparent\n support for transporting images in low-bandwidth compressed formats. Examples (provided by separate\n plugin packages) include JPEG/PNG compression and Theora streaming video.")
    (license license:bsd-3)))

(define-public cv-bridge
  (package
    (name "cv-bridge")
    (version "1.12.8")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/vision_opencv-release.git")
               (commit "release/kinetic/cv_bridge/1.12.8-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0sv9nx279jph4vs4cqq3yg00dy1prgw5gr1c76zgbpprq56k5x19"))))
    (build-system cmake-build-system)
    ;; TODO Make CV-bridge work with this version of OpenCV
    (arguments '(#:tests? #f #:make-flags '("all" "cv_bridge-utest")))
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")
       ("googletest" ,googletest-1.8)
       ("python2-nose" ,python2-nose)
       ("python2-numpy" ,python2-numpy)
       ("rostest" ,rostest)))
    (inputs
      `(("boost" ,boost)
        ("python" ,python)
        ("rosconsole" ,rosconsole)
	("roscpp-serialization" ,roscpp-serialization)
        ("sensor-msgs" ,sensor-msgs)))
    (propagated-inputs
      `(("opencv" ,opencv)
        ("python" ,python)
        ("rosconsole" ,rosconsole)))
    (home-page "http://www.ros.org/wiki/cv_bridge")
    (synopsis
      "This contains CvBridge, which converts between ROS\n Image messages and OpenCV images.")
    (description
      "This contains CvBridge, which converts between ROS\n Image messages and OpenCV images.")
    (license license:bsd-3)))

(define-public kdl-conversions
  (package
    (name "kdl-conversions")
    (version "1.11.9")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/geometry-release.git")
               (commit
                 "release/kinetic/kdl_conversions/1.11.9-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0ckrpffvvglmc8kl443ad8iqnjwjcc19g7d58dd9ilipcb3lsdbx"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
     `(("cpp-common" ,cpp-common)
       ("geometry-msgs" ,geometry-msgs)
       ("orocos-kdl" ,orocos-kdl)
       ("roscpp-serialization" ,roscpp-serialization)))
    (propagated-inputs
     `(("geometry-msgs" ,geometry-msgs)
       ("orocos-kdl" ,orocos-kdl)))
    (home-page "http://ros.org/wiki/kdl_conversions")
    (synopsis
      "Conversion functions between KDL and geometry_msgs types.")
    (description
      "Conversion functions between KDL and geometry_msgs types.")
    (license license:bsd-3)))

(define-public python2-orocos-kdl
  (package
    (name "python2-orocos-kdl")
    (version "1.3.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/smits/orocos-kdl-release.git")
               (commit
                 "release/kinetic/python_orocos_kdl/1.3.2-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0qksys76qghk3iwc67g933fzapidqq96wnh9qbi3g01dpvcj0iac"))))
    (build-system cmake-build-system)
    ;; TODO Run the python tests
    (arguments
     `(#:tests? #f))
    (native-inputs `(("cmake" ,cmake)))
    (inputs
      `(("orocos-kdl" ,orocos-kdl)
        ("python2-sip" ,python2-sip)))
    (propagated-inputs
      `(("catkin" ,catkin)
        ("orocos-kdl" ,orocos-kdl)
        ("python2-sip" ,python2-sip)))
    (home-page
      "http://wiki.ros.org/python_orocos_kdl")
    (synopsis
      "This package contains the python bindings PyKDL for the Kinematics and Dynamics\n Library (KDL), distributed by the Orocos Project.")
    (description
      "This package contains the python bindings PyKDL for the Kinematics and Dynamics\n Library (KDL), distributed by the Orocos Project.")
    (license license:bsd-3)))

(define-public opencv
  (package
    (inherit image-processing:opencv)
    #|
    (name "opencv")
    (version "3.3.1")
    (source (origin
	      (method git-fetch)
	      (uri (git-reference
		    (url "https://github.com/opencv/opencv")
		    (commit version)))
	      (file-name (git-file-name name version))
	      (sha256
	       (base32
		"1z8rbv3b73a9h56jd7f3bhjpllh3nf6a18i7b42yqn68ij9qcgk0"))
	      (modules '((guix build utils)))
	      (snippet
	       '(begin
		  ;; Remove external libraries. We have all available in Guix:
		  (delete-file-recursively "3rdparty")

		  ;; Milky icon set is non-free:
		  (delete-file-recursively "modules/highgui/src/files_Qt/Milky")

		  ;; Some jars found:
		  (for-each delete-file
			    '("modules/java/pure_test/lib/junit-4.11.jar"
			      "samples/java/sbt/sbt/sbt-launch.jar"))
		  #t))))
    (arguments
     `(#:make-flags '("opencv_dnn" "all")
       #:configure-flags
       (list "-DWITH_IPP=OFF"
             "-DWITH_ITT=OFF"
             "-DWITH_CAROTENE=OFF" ; only visible on arm/aarch64
             "-DENABLE_PRECOMPILED_HEADERS=OFF"

             ;; CPU-Features:
             ;; See cmake/OpenCVCompilerOptimizations.cmake
             ;; (CPU_ALL_OPTIMIZATIONS) for a list of all optimizations
             ;; BASELINE is the minimum optimization all CPUs must support
             ;;
             ;; DISPATCH is the list of optional dispatches.
             "-DCPU_BASELINE=SSE2"

             ,@(match (%current-system)
		      ("x86_64-linux"
		       '("-DCPU_DISPATCH=NEON;VFPV3;FP16;SSE;SSE2;SSE3;SSSE3;SSE4_1;SSE4_2;POPCNT;AVX;FP16;AVX2;FMA3;AVX_512F;AVX512_SKX"
			 "-DCPU_DISPATCH_REQUIRE=SSE3,SSSE3,SSE4_1,SSE4_2,AVX,AVX2"))
		      ("armhf-linux"
		       '("-DCPU_BASELINE_DISABLE=NEON")) ; causes build failures
		      ("aarch64-linux"
		       '("-DCPU_BASELINE=NEON"
			 "-DCPU_DISPATCH=NEON;VFPV3;FP16"))
		      (_ '()))

             "-DBUILD_PERF_TESTS=OFF"
             "-DBUILD_TESTS=ON"

             (string-append "-DOPENCV_EXTRA_MODULES_PATH=" (getcwd)
                            "/opencv-contrib/modules")

             ;;Define test data:
             (string-append "-DOPENCV_TEST_DATA_PATH=" (getcwd)
                            "/opencv-extra/testdata")

             ;; Is ON by default and would try to rebuild 3rd-party protobuf,
             ;; which we had removed, which would lead to an error:
             "-DBUILD_PROTOBUF=OFF"

             ;; Rebuild protobuf files, because we have a slightly different
             ;; version than the included one. If we would not update, we
             ;; would get a compile error later:
             "-DPROTOBUF_UPDATE_FILES=ON"

             ;; xfeatures2d disabled, because it downloads extra binaries from
             ;; https://github.com/opencv/opencv_3rdparty
             ;; defined in xfeatures2d/cmake/download_{vgg|bootdesc}.cmake
             ;; Cmp this bug entry:
             ;; https://github.com/opencv/opencv_contrib/issues/1131
             "-DBUILD_opencv_xfeatures2d=OFF")
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'disable-broken-tests
           (lambda _
             ;; These tests fails with:
             ;; vtkXOpenGLRenderWindow (0x723990): Could not find a decent config
             ;; I think we have no OpenGL support with the Xvfb.
             (substitute* '("modules/viz/test/test_tutorial3.cpp"
                            "modules/viz/test/test_main.cpp"
                            "modules/viz/test/tests_simple.cpp"
                            "modules/viz/test/test_viz3d.cpp")
               (("(TEST\\(Viz, )([a-z].*\\).*)" all pre post)
                (string-append pre "DISABLED_" post)))

             ;; Failure reason: Bad accuracy
             ;; Incorrect count of accurate poses [2nd case]: 90.000000 / 94.000000
             (substitute* "../opencv-contrib/modules/rgbd/test/test_odometry.cpp"
               (("(TEST\\(RGBD_Odometry_Rgbd, )(algorithmic\\).*)" all pre post)
                (string-append pre "DISABLED_" post)))
             #t))

         (add-after 'unpack 'unpack-submodule-sources
           (lambda* (#:key inputs #:allow-other-keys)
             (mkdir "../opencv-extra")
             (mkdir "../opencv-contrib")
             (copy-recursively (assoc-ref inputs "opencv-extra")
                               "../opencv-extra")
             (invoke "tar" "xvf"
                     (assoc-ref inputs "opencv-contrib")
                     "--strip-components=1"
                     "-C" "../opencv-contrib")))

         (add-after 'set-paths 'add-ilmbase-include-path
           (lambda* (#:key inputs #:allow-other-keys)
           ;; OpenEXR propagates ilmbase, but its include files do not appear
           ;; in the CPATH, so we need to add "$ilmbase/include/OpenEXR/" to
           ;; the CPATH to satisfy the dependency on "ImathVec.h".
           (setenv "CPATH"
                   (string-append (assoc-ref inputs "ilmbase")
                                  "/include/OpenEXR"
                                  ":" (or (getenv "CPATH") "")))
           #t))
       (add-before 'check 'start-xserver
         (lambda* (#:key inputs #:allow-other-keys)
           (let ((xorg-server (assoc-ref inputs "xorg-server"))
                 (disp ":1"))
             (setenv "HOME" (getcwd))
             (setenv "DISPLAY" disp)
             ;; There must be a running X server and make check doesn't start one.
             ;; Therefore we must do it.
             (zero? (system (format #f "~a/bin/Xvfb ~a &" xorg-server disp)))))))))
    (native-inputs
     `(("pkg-config" ,pkg-config)
       ("xorg-server" ,xorg-server-for-tests) ; For running the tests
       ("opencv-extra"
        ,(origin
           (method git-fetch)
           (uri (git-reference
                  (url "https://github.com/opencv/opencv_extra")
                  (commit version)))
           (file-name (git-file-name "opencv_extra" version))
           (sha256
            (base32 "1ns5wy90jnr8ll4p32qaij1l9yr1gflhqbhlc6zxcqffk0hjni95"))))
       ("opencv-contrib"
        ,(origin
           (method git-fetch)
           (uri (git-reference
                  (url "https://github.com/opencv/opencv_contrib")
                  (commit version)))
           (file-name (git-file-name "opencv_contrib" version))
           (patches (search-patches "opencv-rgbd-aarch64-test-fix.patch"))
           (sha256
            (base32 "0q5vsa8dpa3mdhzas0ckagwh2sbckpm1kxsp0i3yfknsr5ampyi2"))))))
    |#
    (inputs `(("libjpeg" ,libjpeg-turbo)
	      ("libpng" ,libpng)
	      ("jasper" ,jasper)
	      ;; ffmpeg 4.0 causes core dumps in tests.
	      ("ffmpeg" ,ffmpeg-3.4)
	      ("libtiff" ,libtiff)
	      ("hdf5" ,hdf5)
	      ("libgphoto2" ,libgphoto2)
	      ("libwebp" ,libwebp)
	      ("zlib" ,zlib)
	      ("gtkglext" ,gtkglext)
	      ("openexr" ,openexr)
	      ("ilmbase" ,ilmbase)
	      ("gtk+" ,gtk+-2)
	      ("python2-numpy" ,python2-numpy)
	      ("protobuf" ,protobuf)
	      ("vtk" ,image-processing:vtk)
	      ("python2" ,python-2.7)))))

(define-public control-msgs
  (package
    (name "control-msgs")
    (version "1.5.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/control_msgs-release.git")
               (commit "release/kinetic/control_msgs/1.5.1-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0qh0p42gs9g6fh7n7riq9qjafbinr5gr0g8c8ydfxrk1xihi06x7"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("message-generation" ,message-generation)))
    (inputs
     `(("cpp-common", cpp-common)
       ("roscpp-serialization" ,roscpp-serialization)
       ("message-runtime" ,message-runtime)))
    (propagated-inputs
     `(("actionlib-msgs" ,actionlib-msgs)
       ("geometry-msgs" ,geometry-msgs)
       ("std-msgs" ,std-msgs)
       ("trajectory-msgs" ,trajectory-msgs)))
    (home-page "http://ros.org/wiki/control_msgs")
    (synopsis
      "control_msgs contains base messages and actions useful for\n controlling robots. It provides representations for controller\n setpoints and joint and cartesian trajectories.")
    (description
      "control_msgs contains base messages and actions useful for\n controlling robots. It provides representations for controller\n setpoints and joint and cartesian trajectories.")
    (license license:bsd-3)))

(define-public controller-manager-msgs
  (package
    (name "controller-manager-msgs")
    (version "0.13.5")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/ros_control-release.git")
               (commit
                 "release/kinetic/controller_manager_msgs/0.13.5-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "10vnx3g6z6a98hirw2p99yhszx0xrnf9bgq030chxp8a1izhy29m"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
     `(("roscpp", roscpp)
       ("message-generation" ,message-generation)
       ("std-msgs" ,std-msgs)))
    (propagated-inputs
     `(("message-runtime" ,message-runtime)
       ("std-msgs" ,std-msgs)))
    (home-page
      "https://github.com/ros-controls/ros_control/wiki")
    (synopsis
      "Messages and services for the controller manager.")
    (description
      "Messages and services for the controller manager.")
    (license license:bsd-3)))

(define-public warehouse-ros
  (package
    (name "warehouse-ros")
    (version "0.9.4")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/warehouse_ros-release.git")
               (commit "release/kinetic/warehouse_ros/0.9.4-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "14zxzi53nx12pqhrirsjcwfq218p1zl5gyacz0r5m8816lk5ckhr"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")))
    (inputs
      `(("boost" ,boost)
        ("roscpp" ,roscpp)
        ("rostime" ,rostime)
        ("std-msgs" ,std-msgs)
        ("geometry-msgs" ,geometry-msgs)
        ("pluginlib" ,pluginlib)
        ("tf" ,tf)))
    (propagated-inputs
      `(("rostime" ,rostime)
        ("std-msgs" ,std-msgs)
        ("geometry-msgs" ,geometry-msgs)
        ("tf" ,tf)))
    (home-page "http://ros.org/wiki/warehouse_ros")
    (synopsis "Persistent storage of ROS messages")
    (description
      "Persistent storage of ROS messages")
    (license license:bsd-3)))

(define-public interactive-markers
  (package
    (name "interactive-markers")
    (version "1.11.5")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/interactive_markers-release.git")
               (commit
                 "release/kinetic/interactive_markers/1.11.5-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1ni1z7kpl1k4x0hzvmzz5qf93kkgb3p6rvchxbyfy5nwbygw8clx"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("rostest" ,rostest)))
     (inputs
      `(("rosconsole" ,rosconsole)
        ("roscpp" ,roscpp)
        ("rospy" ,rospy)
        ("std-msgs" ,std-msgs)
        ("tf" ,tf)
        ("visualization-msgs" ,visualization-msgs)))
    (propagated-inputs
      `(("rosconsole" ,rosconsole)
        ("roscpp" ,roscpp)
        ("rospy" ,rospy)
        ("std-msgs" ,std-msgs)
        ("tf" ,tf)
        ("visualization-msgs" ,visualization-msgs)))
    (home-page
      "http://ros.org/wiki/interactive_markers")
    (synopsis
      "3D interactive marker communication library for RViz and similar tools.")
    (description
      "3D interactive marker communication library for RViz and similar tools.")
    (license license:bsd-3)))

(define-public eigenpy
  (package
    (name "eigenpy")
    (version "2.3.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ipab-slmc/eigenpy_catkin-release.git")
               (commit "release/kinetic/eigenpy/2.3.1-3")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1qshx5kgviachkqfivw7gg9ljgwc8n0vd5k1fa3yinpygdch31jw"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("boost:dev" ,boost "dev")
       ("pkg-config" ,pkg-config)
       ("cmake" ,cmake)
       ("eigen" ,eigen)
       ("doxygen" ,doxygen)))
    (inputs
     `(;("git" ,git)
       ("boost" ,boost)))
    (propagated-inputs
     `(("python2" ,python-2.7)
       ("python2-numpy" ,python2-numpy)))
    (home-page
      "https://github.com/stack-of-tasks/eigenpy")
    (synopsis
      "Bindings between Numpy and Eigen using Boost.Python")
    (description
      "Bindings between Numpy and Eigen using Boost.Python")
    (license license:bsd-3)))

(define-public rviz
  (package
    (name "rviz")
    (version "1.12.17")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/rviz-release.git")
               (commit "release/kinetic/rviz/1.12.17-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "03ykxqfh7p7vpgcivyx2s4z87mybpnqk4ni2rrn7irzw79hga9aj"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("assimp" ,assimp)
        ("cmake-modules" ,cmake-modules)
        ("eigen" ,eigen)
        ("geometry-msgs" ,geometry-msgs)
        ("image-transport" ,image-transport)
        ("interactive-markers" ,interactive-markers)
        ("laser-geometry" ,laser-geometry)
        ("ogre" ,ogre)
        ("qtbase" ,qtbase)
        ;("libqglviewer" ,libqglviewer)
        ("map-msgs" ,map-msgs)
        ("message-filters" ,message-filters)
        ("nav-msgs" ,nav-msgs)
        ("pluginlib" ,pluginlib)
        ("python2-pyqt" ,python2-pyqt)
        ("resource-retriever" ,resource-retriever)
        ("rosbag" ,rosbag)
        ("rosconsole" ,rosconsole)
        ("roscpp" ,roscpp)
        ("roslib" ,roslib)
        ("rospy" ,rospy)
        ("sensor-msgs" ,sensor-msgs)
        ("std-msgs" ,std-msgs)
        ("std-srvs" ,std-srvs)
        ("tf" ,tf)
        ("tinyxml" ,tinyxml)
        ("urdf" ,urdf)
        ("visualization-msgs" ,visualization-msgs)
        ("yaml-cpp" ,yaml-cpp)
        ("opengl" ,mesa)
        ("urdfdom-headers" ,urdfdom-headers)))
    (propagated-inputs
      `(("assimp" ,assimp)
        ("eigen" ,eigen)
        ("geometry-msgs" ,geometry-msgs)
        ("image-transport" ,image-transport)
        ("interactive-markers" ,interactive-markers)
        ("laser-geometry" ,laser-geometry)
        ("ogre" ,ogre)
        ;("qt5-core" ,qt5-core)
        ;("qt5-gui" ,qt5-gui)
        ;("qt5-widgets" ,qt5-widgets)
        ("map-msgs" ,map-msgs)
        ("media-export" ,media-export)
        ("message-filters" ,message-filters)
        ("nav-msgs" ,nav-msgs)
        ("pluginlib" ,pluginlib)
        ("python2-pyqt" ,python2-pyqt)
        ("resource-retriever" ,resource-retriever)
        ("rosbag" ,rosbag)
        ("rosconsole" ,rosconsole)
        ("roscpp" ,roscpp)
        ("roslib" ,roslib)
        ("rospy" ,rospy)
        ("sensor-msgs" ,sensor-msgs)
        ("std-msgs" ,std-msgs)
        ("std-srvs" ,std-srvs)
        ("tf" ,tf)
        ("tinyxml" ,tinyxml)
        ("urdf" ,urdf)
        ("visualization-msgs" ,visualization-msgs)
        ("yaml-cpp" ,yaml-cpp)
        ("urdfdom-headers" ,urdfdom-headers)))
    (home-page "http://ros.org/wiki/rviz")
    (synopsis "3D visualization tool for ROS.")
    (description "3D visualization tool for ROS.")
    (license license:bsd-3)))

(define-public laser-geometry
  (package
    (name "laser-geometry")
    (version "1.6.5")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/laser_geometry-release.git")
               (commit "release/kinetic/laser_geometry/1.6.5-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1h2xxabbglpgf783kp7av0saiyjkqgrn1611l0dxv5mx6mhivn98"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("boost:dev" ,boost "dev")
       ("eigen" ,eigen)))
    (inputs
      `(("angles" ,angles)
        ("boost" ,boost)
        ("python2-numpy" ,python2-numpy)
        ("roscpp" ,roscpp)
        ("sensor-msgs" ,sensor-msgs)
        ("tf" ,tf)
        ("tf2" ,tf2)))
    (propagated-inputs
      `(("angles" ,angles)
        ("roscpp" ,roscpp)
        ("sensor-msgs" ,sensor-msgs)
        ("tf" ,tf)
        ("tf2" ,tf2)))
    (home-page "http://ros.org/wiki/laser_geometry")
    (synopsis
      "This package contains a class for converting from a 2D laser scan as defined by\n sensor_msgs/LaserScan into a point cloud as defined by sensor_msgs/PointCloud\n or sensor_msgs/PointCloud2. In particular, it contains functionality to account\n for the skew resulting from moving robots or tilting laser scanners.")
    (description
      "This package contains a class for converting from a 2D laser scan as defined by\n sensor_msgs/LaserScan into a point cloud as defined by sensor_msgs/PointCloud\n or sensor_msgs/PointCloud2. In particular, it contains functionality to account\n for the skew resulting from moving robots or tilting laser scanners.")
    (license license:bsd-3)))

(define-public map-msgs
  (package
    (name "map-msgs")
    (version "1.13.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/navigation_msgs-release.git")
               (commit "release/kinetic/map_msgs/1.13.0-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "115vffj9shhidpzjwww9yml7n6jmjw07b6243qr01mkfnfba9k6c"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("message-generation" ,message-generation)))
    (inputs
     `(("cpp-common" ,cpp-common)
       ("message-runtime" ,message-runtime)
       ("roscpp-serialization" ,roscpp-serialization)))
    (propagated-inputs
     `(("std-msgs" ,std-msgs)
       ("sensor-msgs" ,sensor-msgs)
       ("nav-msgs" ,nav-msgs)))
    (home-page "http://ros.org/wiki/map_msgs")
    (synopsis
      "This package defines messages commonly used in mapping packages.")
    (description
      "This package defines messages commonly used in mapping packages.")
    (license license:bsd-3)))

(define-public nav-msgs
  (package
    (name "nav-msgs")
    (version "1.12.7")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/common_msgs-release.git")
               (commit "release/kinetic/nav_msgs/1.12.7-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1xzg8x6fn0kb799d4ianh5sxwmxr2rl3nm20xr7adw2a86v4g1jp"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("catkin" ,catkin)
       ("message-generation" ,message-generation)))
    (inputs
     `(("cpp-common" ,cpp-common)
       ("message-runtime" ,message-runtime)
       ("roscpp-serialization" ,roscpp-serialization)))
    (propagated-inputs
     `(("actionlib-msgs" ,actionlib-msgs)
       ("geometry-msgs" ,geometry-msgs)
       ("std-msgs" ,std-msgs)))
    (home-page "http://wiki.ros.org/nav_msgs")
    (synopsis
      "nav_msgs defines the common messages used to interact with the\n <a href=\"http://wiki.ros.org/navigation\">navigation</a> stack.")
    (description
      "nav_msgs defines the common messages used to interact with the\n <a href=\"http://wiki.ros.org/navigation\">navigation</a> stack.")
    (license license:bsd-3)))

(define-public media-export
  (package
    (name "media-export")
    (version "0.3.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/media_export-release.git")
               (commit "release/kinetic/media_export/0.3.0-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0qj4asvjzlclk3q181i4wqjmp6d7a05056sw9wx8nr3k24dq5wvh"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (home-page "http://ros.org/wiki/media_export")
    (synopsis
      "Placeholder package enabling generic export of media paths.")
    (description
      "Placeholder package enabling generic export of media paths.")
    (license license:bsd-3)))

(define-public roslint
  (package
    (name "roslint")
    (version "0.11.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/roslint-release.git")
               (commit "release/kinetic/roslint/0.11.0-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1q89hf72dpqnkgggl5wil078whdv94amh4zx743f7ivwm341206w"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (home-page "http://ros.org/wiki/roslint")
    (synopsis
      "CMake lint commands for ROS packages.\n\n The lint commands perform static checking of Python or C++ source\n code for errors and standards compliance.")
    (description
      "CMake lint commands for ROS packages.\n\n The lint commands perform static checking of Python or C++ source\n code for errors and standards compliance.")
    (license license:bsd-3)))
