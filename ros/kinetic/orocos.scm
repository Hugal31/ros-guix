(define-module (ros kinetic orocos)
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
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages image)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages time)
  #:use-module (gnu packages qt)
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
  #:use-module (ice-9 ftw)
  #:use-module (log4cxx)
  #:use-module (console-bridge)
  #:use-module (ros kinetic base)
  #:use-module (ros kinetic ros-tools)
  #:use-module (ros kinetic poco)
  #:use-module (ros kinetic urdfdom))

;; TODO There must be a better way to have a subdir CMakeLists.txt
(define (cmake-list-subdir-arguments subdir)
  `(#:configure-flags
    `("-S" ,(string-append (getcwd) "/source/" ,subdir))))

(define rtt-ros-integration-base
  (package
   (name "rtt-ros-integration-base")
   (version "2.9.3-rc1")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/orocos/rtt_ros_integration.git")
           (commit "c65cf80ce5ae07536fb5542b314f081e7e930d2d")))
     (file-name (git-file-name name version))
     (sha256
      (base32
       "1nxnbkrydx29v0kxran4r3izh7g35byhp09g5vvxw6kblq3rp22v"))))
   (build-system cmake-build-system)
   (native-inputs `(("catkin" ,catkin)))
   (home-page
    "http://ros.org/wiki/rtt_ros_integration")
   (synopsis
    "Orocos-ROS interoperability library")
   (description
    "This stack contains all software necessary to build systems using both Orocos and ROS infrastructures")
   (license license:bsd-3)))

(define-public rtt-ros-integration
  (package
   (inherit rtt-ros-integration-base)
   (name "rtt-ros-integration")
   (arguments (cmake-list-subdir-arguments "rtt_ros_integration"))
   (propagated-inputs
    `(("rtt-actionlib" ,rtt-actionlib) ; TODO expand
     ))))

(define-public rtt-actionlib
  (package
   (inherit rtt-ros-integration-base)
   (name "rtt-actionlib")
   (arguments (cmake-list-subdir-arguments "rtt_actionlib"))
   (inputs
    `(("actionlib" ,actionlib)
      ("roscpp" ,roscpp)
      ("rtt-ros" ,rtt-ros)))
   (synopsis "Orocos interoperability library with ROS actionlib")
   (description"Orocos interoperability library with ROS actionlib")))

(define-public rtt-ros
  (package
   (inherit rtt-ros-integration-base)
   (name "rtt-ros")
   (arguments (cmake-list-subdir-arguments "rtt_ros"))
   (native-inputs `(("catkin" ,catkin)))
   (inputs
    `(("rtt" ,rtt)
      ("ocl" ,ocl)
      ("rostime" ,rostime)
      ("rospack" ,rospack)
      ("roslib" ,roslib)
      ("xml2" ,xml2)))
   (home-page
    "http://ros.org/wiki/rtt_ros_integration")
   (synopsis
    "This package provides an RTT plugin to add a ROS node to the RTT process,\n as well as several wrapper scripts to enable roslaunching of orocos\n programs.")
   (description
    "This package provides an RTT plugin to add a ROS node to the RTT process,\n as well as several wrapper scripts to enable roslaunching of orocos\n programs.")))

(define-public rtt
  (package
    (name "rtt")
    (version "2.9.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/orocos-gbp/rtt-release.git")
               (commit "release/kinetic/rtt/2.9.2-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0a37yb5pzj60gjwl5p1ahlv5krf58lmcsgcp0ynx44w1fhyzkmnw"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("cmake" ,cmake) ("catkin" ,catkin)))
    (inputs
      `(("xpath-perl" ,xpath-perl)
        ("boost" ,boost)
        ("omniorb" ,omniorb)
        ("pkg-config" ,pkg-config)))
    (propagated-inputs
      `(("catkin" ,catkin)
        ("boost" ,boost)
        ("omniorb" ,omniorb)
        ("xpath-perl" ,xpath-perl)
        ("pkg-config" ,pkg-config)))
    (home-page "http://www.orocos.org/rtt")
    (synopsis "Orocos/RTT component framework")
    (description "Orocos/RTT component framework")
    (license license:bsd-3)))
(define-public ocl
  (package
    (name "ocl")
    (version "2.9.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/orocos-gbp/ocl-release.git")
               (commit "release/kinetic/ocl/2.9.2-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1djv8z1m09340wsk354yyv89lwmgl08k8xjjlv6z4yak10x0la72"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("cmake" ,cmake) ("catkin" ,catkin)))
    (inputs
      `(("readline" ,readline)
        ("ncurses" ,ncurses)
        ("lua" ,lua)
        ("netcdf" ,netcdf)
        ("rtt" ,rtt)
        ("log4cpp" ,log4cpp)))
    (propagated-inputs
      `(("catkin" ,catkin)
        ("readline" ,readline)
        ("ncurses" ,ncurses)
        ("lua" ,lua)
        ("netcdf" ,netcdf)
        ("rtt" ,rtt)
        ("log4cpp" ,log4cpp)))
    (home-page "http://www.orocos.org/ocl")
    (synopsis
      "Orocos component library\n This package contains standard components for the Orocos Toolchain")
    (description
      "Orocos component library\n This package contains standard components for the Orocos Toolchain")
    (license license:bsd-3)))
