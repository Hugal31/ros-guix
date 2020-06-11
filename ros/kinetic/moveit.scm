(define-module (ros kinetic moveit)
  #:use-module ((guix licenses) #:prefix license:)
  ;#:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  ;#:use-module (guix download)
  ;#:use-module (guix gexp)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages serialization)
  ;#:use-module (guix build-system python)
  ;#:use-module (guix build-system gnu)
  ;#:use-module (gnu packages)
  ;#:use-module (gnu packages ssh)
  ;#:use-module (gnu packages web)
  ;#:use-module (gnu packages time)
  ;#:use-module (gnu packages gcc)
  ;#:use-module (gnu packages qt)
  ;#:use-module (gnu packages graphviz)
  ;#:use-module (gnu packages python-xyz)
  ;#:use-module (gnu packages python-crypto)
  ;#:use-module (gnu packages perl)
  ;#:use-module (gnu packages shells)
  ;#:use-module (gnu packages maths)
  ;#:use-module (gnu packages compression)
  ;#:use-module (gnu packages xml)
  ;#:use-module (gnu packages algebra)
  ;#:use-module (gnu packages check)
  ;#:use-module (gnu packages apr)
  ;#:use-module (gnu packages cmake)
  ;#:use-module (gnu packages linux)
  ;#:use-module (gnu packages guile)
  ;#:use-module (gnu packages wxwidgets)
  ;#:use-module (gnu packages tls)
  ;#:use-module (ice-9 ftw)
  ; #:use-module (log4cxx)
  #:use-module (fcl)
  #:use-module (console-bridge)
  #:use-module (ros kinetic base)
  #:use-module (ros kinetic ros-tools)
  ; #:use-module (ros kinetic poco)
  #:use-module (ros kinetic urdfdom)
  )

(define-public moveit
  (package
    (name "moveit")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit "release/kinetic/moveit/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0358y600cd4d2x5gbicw4w3xrr2s7i3fy8jjlcqf42dmjzgz79x0"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(;("moveit-commander" ,moveit-commander)
        ("moveit-core" ,moveit-core)
        ("moveit-planners" ,moveit-planners)
        ("moveit-plugins" ,moveit-plugins)
        ("moveit-ros" ,moveit-ros)
        ("moveit-setup-assistant"
         ,moveit-setup-assistant)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Meta package that contains all essential package of MoveIt!. Until Summer 2016 MoveIt! had been developed over multiple repositories, where developers' usability and maintenance effort was non-trivial. See <a href=\"http://discourse.ros.org/t/migration-to-one-github-repo-for-moveit/266/34\">the detailed discussion for the merge of several repositories</a>.")
    (description
      "Meta package that contains all essential package of MoveIt!. Until Summer 2016 MoveIt! had been developed over multiple repositories, where developers' usability and maintenance effort was non-trivial. See <a href=\"http://discourse.ros.org/t/migration-to-one-github-repo-for-moveit/266/34\">the detailed discussion for the merge of several repositories</a>.")
    (license license:bsd-3)))

(define-public moveit-core
  (package
    (name "moveit-core")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit "release/kinetic/moveit_core/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1j1ps4b7i0d51423x19wdham8965pakg20wwg7cfr6vc3cxck56n"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("boost:dev" ,boost "dev")
       ("catkin" ,catkin)
       ("eigen" ,eigen)
       ("eigen-conversions" ,eigen-conversions)
       ("eigen-stl-containers" ,eigen-stl-containers)
       ("pkg-config" ,pkg-config)))
    (inputs
      `(("assimp" ,assimp)
        ("boost" ,boost)
        ("fcl" ,fcl)
        ("geometric-shapes" ,geometric-shapes)
        ("geometry-msgs" ,geometry-msgs)
        ("kdl-parser" ,kdl-parser)
        ("console-bridge" ,console-bridge)
        ("urdf" ,urdf)
        ("urdfdom" ,urdfdom)
        ("urdfdom-headers" ,urdfdom-headers)
        ("moveit-msgs" ,moveit-msgs)
        ("octomap" ,octomap)
        ("octomap-msgs" ,octomap-msgs)
        ("random-numbers" ,random-numbers)
        ("roslib" ,roslib)
        ("rostime" ,rostime)
        ("rosconsole" ,rosconsole)
        ("sensor-msgs" ,sensor-msgs)
        ("shape-msgs" ,shape-msgs)
        ("srdfdom" ,srdfdom)
        ("std-msgs" ,std-msgs)
        ("trajectory-msgs" ,trajectory-msgs)
        ("visualization-msgs" ,visualization-msgs)
        ("xmlrpcpp" ,xmlrpcpp)))
    (propagated-inputs
      `(("assimp" ,assimp)
        ("fcl" ,fcl)
        ("geometric-shapes" ,geometric-shapes)
        ("geometry-msgs" ,geometry-msgs)
        ("kdl-parser" ,kdl-parser)
        ("console-bridge" ,console-bridge)
        ("urdf" ,urdf)
        ("urdfdom" ,urdfdom)
        ("urdfdom-headers" ,urdfdom-headers)
        ("moveit-msgs" ,moveit-msgs)
        ("octomap" ,octomap)
        ("octomap-msgs" ,octomap-msgs)
        ("random-numbers" ,random-numbers)
        ("rostime" ,rostime)
        ("rosconsole" ,rosconsole)
        ("sensor-msgs" ,sensor-msgs)
        ("srdfdom" ,srdfdom)
        ("std-msgs" ,std-msgs)
        ("trajectory-msgs" ,trajectory-msgs)
        ("visualization-msgs" ,visualization-msgs)))
    (home-page "http://moveit.ros.org")
    (synopsis "Core libraries used by MoveIt!")
    (description "Core libraries used by MoveIt!")
    (license license:bsd-3)))

(define-public moveit-setup-assistant
  (package
    (name "moveit-setup-assistant")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_setup_assistant/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0cb2bk64k1k83zhqwambmmniz3xifzm47xyava6hczl5fgkprdjj"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("moveit-core" ,moveit-core)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("moveit-ros-visualization"
         ,moveit-ros-visualization)
        ("yaml-cpp" ,yaml-cpp)
        ("roscpp" ,roscpp)
        ("rviz" ,rviz)
        ("srdfdom" ,srdfdom)
        ("urdf" ,urdf)))
    (propagated-inputs
      `(("moveit-core" ,moveit-core)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("moveit-ros-visualization"
         ,moveit-ros-visualization)
        ("yaml-cpp" ,yaml-cpp)
        ("xacro" ,xacro)
        ("roscpp" ,roscpp)
        ("rviz" ,rviz)
        ("srdfdom" ,srdfdom)
        ("urdf" ,urdf)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Generates a configuration package that makes it easy to use MoveIt!")
    (description
      "Generates a configuration package that makes it easy to use MoveIt!")
    (license license:bsd-3)))

#|
(define-public moveit-commander
  (package
    (name "moveit-commander")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_commander/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "06nb5jmy1h1v5w28m4zrqdwvwrddfxd7y14c2gs5vlbgc06dpwvk"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("python2-catkin-pkg" ,python2-catkin-pkg)))
    (inputs `(("python" ,python)))
    (propagated-inputs
      `(("geometry-msgs" ,geometry-msgs)
        ("moveit-msgs" ,moveit-msgs)
        ("moveit-ros-planning-interface" ,moveit-ros-planning-interface)
        ("python" ,python)
        ("python2-pyassimp" ,python2-pyassimp)
        ("rospy" ,rospy)
        ("sensor-msgs" ,sensor-msgs)
        ("shape-msgs" ,shape-msgs)
        ("tf" ,tf)))
    (home-page "http://moveit.ros.org")
    (synopsis "Python interfaces to MoveIt")
    (description "Python interfaces to MoveIt")
    (license license:bsd-3)))
|#

(define-public moveit-ros
  (package
    (name "moveit-ros")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit "release/kinetic/moveit_ros/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0ymlkcvy96dyfr54qpcn1by0sx48lazxcvpahygrkfr5ybw4l822"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("moveit-ros-perception" ,moveit-ros-perception)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("moveit-ros-warehouse" ,moveit-ros-warehouse)
        ("moveit-ros-benchmarks" ,moveit-ros-benchmarks)
        ("moveit-ros-robot-interaction"
         ,moveit-ros-robot-interaction)
        ("moveit-ros-planning-interface"
         ,moveit-ros-planning-interface)
        ("moveit-ros-visualization"
         ,moveit-ros-visualization)
        ("moveit-ros-manipulation"
         ,moveit-ros-manipulation)
        ("moveit-ros-move-group" ,moveit-ros-move-group)))
    (home-page "http://moveit.ros.org")
    (synopsis "Components of MoveIt! that use ROS")
    (description
      "Components of MoveIt! that use ROS")
    (license license:bsd-3)))
(define-public moveit-plugins
  (package
    (name "moveit-plugins")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_plugins/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "05i9ik6hanw06jhydm3qgnbzf71qv6zkixiybiv761rqag5skwa1"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("moveit-simple-controller-manager"
         ,moveit-simple-controller-manager)
        ("moveit-fake-controller-manager"
         ,moveit-fake-controller-manager)
        ("moveit-ros-control-interface"
         ,moveit-ros-control-interface)))
    (home-page "http://moveit.ros.org")
    (synopsis "Metapackage for moveit plugins.")
    (description "Metapackage for moveit plugins.")
    (license license:bsd-3)))
(define-public moveit-planners
  (package
    (name "moveit-planners")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_planners/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "13pr95x4z54b68v1ljfdzbw74dh2k167im2pjk4rrfj9dzfaav27"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (propagated-inputs
      `(("chomp-motion-planner" ,chomp-motion-planner)
        ("moveit-planners-chomp" ,moveit-planners-chomp)
        ("moveit-planners-ompl" ,moveit-planners-ompl)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Metapacakge that installs all available planners for MoveIt")
    (description
      "Metapacakge that installs all available planners for MoveIt")
    (license license:bsd-3)))

(define-public moveit-ros-benchmarks
  (package
    (name "moveit-ros-benchmarks")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_ros_benchmarks/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1wqfsv5bmm1la2w124ahrcl13rz6m8clgnq1s2ai784cwnc4avf2"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("moveit-ros-planning" ,moveit-ros-planning)
        ("moveit-ros-warehouse" ,moveit-ros-warehouse)
        ("roscpp" ,roscpp)
        ("pluginlib" ,pluginlib)))
    (propagated-inputs
      `(("moveit-ros-planning" ,moveit-ros-planning)
        ("moveit-ros-warehouse" ,moveit-ros-warehouse)
        ("roscpp" ,roscpp)
        ("pluginlib" ,pluginlib)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Enhanced tools for benchmarks in MoveIt!")
    (description
      "Enhanced tools for benchmarks in MoveIt!")
    (license license:bsd-3)))

(define-public moveit-ros-planning-interface
  (package
    (name "moveit-ros-planning-interface")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_ros_planning_interface/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0yb42vi9qg1rhbprrw6v148c52ixjmpk1cq9gi9q9cb7gaw83ik7"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin)
        ("python2-catkin-pkg" ,python2-catkin-pkg)))
    (inputs
      `(("moveit-ros-planning" ,moveit-ros-planning)
        ("moveit-ros-warehouse" ,moveit-ros-warehouse)
        ("moveit-ros-move-group" ,moveit-ros-move-group)
        ("moveit-ros-manipulation"
         ,moveit-ros-manipulation)
        ("moveit-msgs" ,moveit-msgs)
        ("roscpp" ,roscpp)
        ("rospy" ,rospy)
        ("rosconsole" ,rosconsole)
        ("actionlib" ,actionlib)
        ("tf" ,tf)
        ("eigen-conversions" ,eigen-conversions)
        ("tf-conversions" ,tf-conversions)
        ("python" ,python)
        ("eigen" ,eigen)
        ("eigenpy" ,eigenpy)))
    (propagated-inputs
      `(("moveit-ros-planning" ,moveit-ros-planning)
        ("moveit-ros-warehouse" ,moveit-ros-warehouse)
        ("moveit-ros-move-group" ,moveit-ros-move-group)
        ("moveit-ros-manipulation"
         ,moveit-ros-manipulation)
        ("moveit-msgs" ,moveit-msgs)
        ("roscpp" ,roscpp)
        ("rospy" ,rospy)
        ("rosconsole" ,rosconsole)
        ("actionlib" ,actionlib)
        ("tf" ,tf)
        ("eigen-conversions" ,eigen-conversions)
        ("tf-conversions" ,tf-conversions)
        ("python" ,python)
        ("eigenpy" ,eigenpy)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Components of MoveIt! that offer simpler interfaces to planning and execution")
    (description
      "Components of MoveIt! that offer simpler interfaces to planning and execution")
    (license license:bsd-3)))

(define-public chomp-motion-planner
  (package
    (name "chomp-motion-planner")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/chomp_motion_planner/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0k7jf4xjfjchyih6jqa5yy8v9fhdfixhxqz0lsxpi6xxw3bdcqqa"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("roscpp" ,roscpp) ("moveit-core" ,moveit-core)))
    (home-page
      "http://ros.org/wiki/chomp_motion_planner")
    (synopsis "chomp_motion_planner")
    (description "chomp_motion_planner")
    (license license:bsd-3)))

(define-public moveit-ros-warehouse
  (package
    (name "moveit-ros-warehouse")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_ros_warehouse/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0jgph8xpqjf9p7wpnvzc6y38rmignq5f8lsjq8dj41lzd47p5gdr"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("warehouse-ros" ,warehouse-ros)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("roscpp" ,roscpp)
        ("rosconsole" ,rosconsole)
        ("tf" ,tf)))
    (propagated-inputs
      `(("warehouse-ros" ,warehouse-ros)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("roscpp" ,roscpp)
        ("rosconsole" ,rosconsole)
        ("tf" ,tf)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Components of MoveIt! connecting to MongoDB")
    (description
      "Components of MoveIt! connecting to MongoDB")
    (license license:bsd-3)))

(define-public moveit-ros-planning
  (package
    (name "moveit-ros-planning")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_ros_planning/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1mybwdbm6l4n541v1rvy9nkc1pmpgbn1cff81cwg6sknlwhwskds"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("actionlib" ,actionlib)
        ("cmake-modules" ,cmake-modules)
        ("chomp-motion-planner" ,chomp-motion-planner)
        ("dynamic-reconfigure" ,dynamic-reconfigure)
        ("eigen" ,eigen)
        ("eigen-conversions" ,eigen-conversions)
        ("message-filters" ,message-filters)
        ("moveit-core" ,moveit-core)
        ("moveit-msgs" ,moveit-msgs)
        ("moveit-ros-perception" ,moveit-ros-perception)
        ("pluginlib" ,pluginlib)
        ("roscpp" ,roscpp)
        ("srdfdom" ,srdfdom)
        ("urdf" ,urdf)
        ("tf" ,tf)
        ("tf-conversions" ,tf-conversions)))
    (propagated-inputs
      `(("actionlib" ,actionlib)
        ("chomp-motion-planner" ,chomp-motion-planner)
        ("dynamic-reconfigure" ,dynamic-reconfigure)
        ("eigen-conversions" ,eigen-conversions)
        ("message-filters" ,message-filters)
        ("moveit-core" ,moveit-core)
        ("moveit-msgs" ,moveit-msgs)
        ("moveit-ros-perception" ,moveit-ros-perception)
        ("pluginlib" ,pluginlib)
        ("tf" ,tf)
        ("tf-conversions" ,tf-conversions)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Planning components of MoveIt! that use ROS")
    (description
      "Planning components of MoveIt! that use ROS")
    (license license:bsd-3)))

(define-public moveit-ros-visualization
  (package
    (name "moveit-ros-visualization")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_ros_visualization/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0kfqx4k934r3dvrwh5h6c6xc73v1pglj0n28y2lz2vzhz6fy9w15"))))
    (build-system cmake-build-system)
    (native-inputs
      `(("catkin" ,catkin) ("pkg-config" ,pkg-config)))
    (inputs
      `(("class-loader" ,class-loader)
        ("eigen" ,eigen)
        ("eigen-conversions" ,eigen-conversions)
        ("geometric-shapes" ,geometric-shapes)
        ("interactive-markers" ,interactive-markers)
        ("moveit-ros-robot-interaction"
         ,moveit-ros-robot-interaction)
        ("moveit-ros-perception" ,moveit-ros-perception)
        ("moveit-ros-planning-interface"
         ,moveit-ros-planning-interface)
        ("moveit-ros-warehouse" ,moveit-ros-warehouse)
        ("object-recognition-msgs"
         ,object-recognition-msgs)
        ("pluginlib" ,pluginlib)
        ("rosconsole" ,rosconsole)
        ("roscpp" ,roscpp)
        ("rospy" ,rospy)
        ("rviz" ,rviz)
        ("tf" ,tf)))
    (propagated-inputs
      `(("geometric-shapes" ,geometric-shapes)
        ("interactive-markers" ,interactive-markers)
        ("moveit-ros-robot-interaction"
         ,moveit-ros-robot-interaction)
        ("moveit-ros-perception" ,moveit-ros-perception)
        ("moveit-ros-planning-interface"
         ,moveit-ros-planning-interface)
        ("moveit-ros-warehouse" ,moveit-ros-warehouse)
        ("object-recognition-msgs"
         ,object-recognition-msgs)
        ("pluginlib" ,pluginlib)
        ("roscpp" ,roscpp)
        ("rospy" ,rospy)
        ("rviz" ,rviz)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Components of MoveIt! that offer visualization")
    (description
      "Components of MoveIt! that offer visualization")
    (license license:bsd-3)))

(define-public moveit-planners-chomp
  (package
    (name "moveit-planners-chomp")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_planners_chomp/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1sglsb4f3zqcl7yd47x7y788z3dq6rslgs6yw0rdwrizmns4i8a1"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("roscpp" ,roscpp)
        ("moveit-core" ,moveit-core)
        ("pluginlib" ,pluginlib)
        ("chomp-motion-planner" ,chomp-motion-planner)
        ("tf" ,tf)))
    (propagated-inputs
      `(("roscpp" ,roscpp)
        ("moveit-core" ,moveit-core)
        ("pluginlib" ,pluginlib)
        ("chomp-motion-planner" ,chomp-motion-planner)
        ("tf" ,tf)))
    (home-page "http://wiki.ros.org")
    (synopsis
      "The interface for using CHOMP within MoveIt!")
    (description
      "The interface for using CHOMP within MoveIt!")
    (license license:bsd-3)))

(define-public moveit-fake-controller-manager
  (package
    (name "moveit-fake-controller-manager")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_fake_controller_manager/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1nxqh4hi5fw3j87710f2dcicw5q6af7jxh2j44js3i3b7gs9z9w2"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("moveit-core" ,moveit-core)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("pluginlib" ,pluginlib)
        ("roscpp" ,roscpp)))
    (propagated-inputs
      `(("moveit-core" ,moveit-core)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("pluginlib" ,pluginlib)
        ("roscpp" ,roscpp)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "A fake controller manager plugin for MoveIt.")
    (description
      "A fake controller manager plugin for MoveIt.")
    (license license:bsd-3)))

(define-public moveit-planners-ompl
  (package
    (name "moveit-planners-ompl")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_planners_ompl/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0r6nbg32vsfxig8zbngkcixjdrkc3bj3k58kk7138mckv1s7hhz4"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("moveit-core" ,moveit-core)
        ("ompl" ,ompl)
        ("eigen-conversions" ,eigen-conversions)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("dynamic-reconfigure" ,dynamic-reconfigure)
        ("roscpp" ,roscpp)
        ("rosconsole" ,rosconsole)
        ("tf" ,tf)
        ("pluginlib" ,pluginlib)))
    (propagated-inputs
      `(("moveit-core" ,moveit-core)
        ("ompl" ,ompl)
        ("eigen-conversions" ,eigen-conversions)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("dynamic-reconfigure" ,dynamic-reconfigure)
        ("roscpp" ,roscpp)
        ("tf" ,tf)
        ("pluginlib" ,pluginlib)))
    (home-page "http://moveit.ros.org")
    (synopsis "MoveIt! interface to OMPL")
    (description "MoveIt! interface to OMPL")
    (license license:bsd-3)))

(define-public moveit-msgs
  (package
    (name "moveit-msgs")
    (version "0.9.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit_msgs-release.git")
               (commit "release/kinetic/moveit_msgs/0.9.1-0")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "16iv43y4yg5sv48mjgjcbcl0463whalxzvh29pw7qm5n882skysw"))))
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
       ("message-runtime" ,message-runtime)
       ("object-recognition-msgs" ,object-recognition-msgs)
       ("octomap-msgs" ,octomap-msgs)
       ("sensor-msgs" ,sensor-msgs)
       ("shape-msgs" ,shape-msgs)
       ("std-msgs" ,std-msgs)
       ("trajectory-msgs" ,trajectory-msgs)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Messages, services and actions used by MoveIt")
    (description
      "Messages, services and actions used by MoveIt")
    (license license:bsd-3)))

(define-public moveit-ros-robot-interaction
  (package
    (name "moveit-ros-robot-interaction")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_ros_robot_interaction/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1cdsl42faz1a2081hrw53cs14jwsryfyiyndgky41bliq2s9k44r"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("moveit-ros-planning" ,moveit-ros-planning)
        ("roscpp" ,roscpp)
        ("tf" ,tf)
        ("tf-conversions" ,tf-conversions)
        ("eigen-conversions" ,eigen-conversions)
        ("interactive-markers" ,interactive-markers)
        ("pluginlib" ,pluginlib)))
    (propagated-inputs
      `(("moveit-ros-planning" ,moveit-ros-planning)
        ("roscpp" ,roscpp)
        ("tf" ,tf)
        ("tf-conversions" ,tf-conversions)
        ("eigen-conversions" ,eigen-conversions)
        ("interactive-markers" ,interactive-markers)
        ("pluginlib" ,pluginlib)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Components of MoveIt! that offer interaction via interactive markers")
    (description
      "Components of MoveIt! that offer interaction via interactive markers")
    (license license:bsd-3)))

(define-public moveit-ros-control-interface
  (package
    (name "moveit-ros-control-interface")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_ros_control_interface/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0hw9fr66bbhm7zfpr9nv179i9gh34xsaky19m41lzvnlsbwq4pb5"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("actionlib" ,actionlib)
        ("controller-manager-msgs"
         ,controller-manager-msgs)
        ("moveit-core" ,moveit-core)
        ("moveit-simple-controller-manager"
         ,moveit-simple-controller-manager)
        ("pluginlib" ,pluginlib)
        ("trajectory-msgs" ,trajectory-msgs)))
    (propagated-inputs
      `(("actionlib" ,actionlib)
        ("controller-manager-msgs"
         ,controller-manager-msgs)
        ("moveit-core" ,moveit-core)
        ("moveit-simple-controller-manager"
         ,moveit-simple-controller-manager)
        ("pluginlib" ,pluginlib)
        ("trajectory-msgs" ,trajectory-msgs)))
    (home-page "http://wiki.ros.org")
    (synopsis
      "ros_control controller manager interface for MoveIt!")
    (description
      "ros_control controller manager interface for MoveIt!")
    (license license:bsd-3)))

(define-public moveit-simple-controller-manager
  (package
    (name "moveit-simple-controller-manager")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_simple_controller_manager/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0bvs0w156f3swj8n7nwkb8xn80bkn5k4a84jb3mg09aib9m58ky9"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("moveit-core" ,moveit-core)
        ("roscpp" ,roscpp)
        ("pluginlib" ,pluginlib)
        ("control-msgs" ,control-msgs)
        ("actionlib" ,actionlib)))
    (propagated-inputs
      `(("moveit-core" ,moveit-core)
        ("roscpp" ,roscpp)
        ("pluginlib" ,pluginlib)
        ("control-msgs" ,control-msgs)
        ("actionlib" ,actionlib)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "A generic, simple controller manager plugin for MoveIt.")
    (description
      "A generic, simple controller manager plugin for MoveIt.")
    (license license:bsd-3)))

(define-public moveit-ros-move-group
  (package
    (name "moveit-ros-move-group")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_ros_move_group/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "079zayhi1p218bs0k0b7n9pq3vfmsmfk0cyfhcz3whyw08aqby57"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("moveit-core" ,moveit-core)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("actionlib" ,actionlib)
        ("tf" ,tf)
        ("pluginlib" ,pluginlib)
        ("std-srvs" ,std-srvs)
        ("roscpp" ,roscpp)))
    (propagated-inputs
      `(("moveit-core" ,moveit-core)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("moveit-kinematics" ,moveit-kinematics)
        ("actionlib" ,actionlib)
        ("tf" ,tf)
        ("pluginlib" ,pluginlib)
        ("std-srvs" ,std-srvs)
        ("roscpp" ,roscpp)))
    (home-page "http://moveit.ros.org")
    (synopsis "The move_group node for MoveIt")
    (description "The move_group node for MoveIt")
    (license license:bsd-3)))

(define-public moveit-ros-perception
  (package
    (name "moveit-ros-perception")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_ros_perception/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1h0mhkbi19hwbjk1dskpp5glpajjg27w1383v97lshcbk8sqmls1"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("moveit-core" ,moveit-core)
        ("roscpp" ,roscpp)
        ("rosconsole" ,rosconsole)
        ("urdf" ,urdf)
        ("tf" ,tf)
        ("tf-conversions" ,tf-conversions)
        ("message-filters" ,message-filters)
        ("object-recognition-msgs"
         ,object-recognition-msgs)
        ("octomap" ,octomap)
        ("pluginlib" ,pluginlib)
        ("image-transport" ,image-transport)
        ("glew" ,glew)
                                        ; ("opengl" ,opengl)
                                        ; Replace opengl
        ("glu" ,glu)
        ("cv-bridge" ,cv-bridge)
        ("sensor-msgs" ,sensor-msgs)
        ("moveit-msgs" ,moveit-msgs)
        ("eigen" ,eigen)))
    (propagated-inputs
      `(("moveit-core" ,moveit-core)
        ("roscpp" ,roscpp)
        ("rosconsole" ,rosconsole)
        ("urdf" ,urdf)
        ("tf" ,tf)
        ("tf-conversions" ,tf-conversions)
        ("message-filters" ,message-filters)
        ("octomap" ,octomap)
        ("pluginlib" ,pluginlib)
        ("image-transport" ,image-transport)
        ("freeglut" ,freeglut)
        ("glew" ,glew)
                                        ; ("opengl" ,opengl)
        ("cv-bridge" ,cv-bridge)
        ("sensor-msgs" ,sensor-msgs)
        ("moveit-msgs" ,moveit-msgs)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Components of MoveIt! connecting to perception")
    (description
      "Components of MoveIt! connecting to perception")
    (license license:bsd-3)))

(define-public moveit-ros-manipulation
  (package
    (name "moveit-ros-manipulation")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_ros_manipulation/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0ifvq7vkxvm4mm9wx4302lbhf9zsja4yfbdw7bb8nb0qzz46gzjk"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("actionlib" ,actionlib)
        ("dynamic-reconfigure" ,dynamic-reconfigure)
        ("moveit-core" ,moveit-core)
        ("moveit-ros-move-group" ,moveit-ros-move-group)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("moveit-msgs" ,moveit-msgs)
        ("roscpp" ,roscpp)
        ("rosconsole" ,rosconsole)
        ("tf" ,tf)
        ("pluginlib" ,pluginlib)
        ("eigen" ,eigen)))
    (propagated-inputs
      `(("actionlib" ,actionlib)
        ("dynamic-reconfigure" ,dynamic-reconfigure)
        ("moveit-core" ,moveit-core)
        ("moveit-ros-move-group" ,moveit-ros-move-group)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("moveit-msgs" ,moveit-msgs)
        ("roscpp" ,roscpp)
        ("rosconsole" ,rosconsole)
        ("tf" ,tf)
        ("pluginlib" ,pluginlib)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Components of MoveIt! used for manipulation")
    (description
      "Components of MoveIt! used for manipulation")
    (license license:bsd-3)))

(define-public ompl
  (package
    (name "ompl")
    (version "1.2.3")
    (source
     (origin
      (method git-fetch)
      (uri (git-reference
	    (url "https://github.com/ros-gbp/ompl-release.git")
	    (commit "release/kinetic/ompl/1.2.3-1")))
      (file-name (git-file-name name version))
      (sha256
       (base32
	"032i5yax9dajkp4ag78c8nxaawky50kc1pbyczwp8yh4z87sks2a"))
      (patches
       (search-patches
	"ros/kinetic/patches/ompl-remove-machine-test.patch"
	"ros/kinetic/patches/ompl-test-resources-readonly.patch"))))
    (build-system cmake-build-system)
    (native-inputs
     `(("boost:dev" ,boost "dev")
                                        ;("cmake" ,cmake)
       ("eigen" ,eigen)))
    (inputs `(("boost" ,boost)))
    (home-page "http://ompl.kavrakilab.org")
    (synopsis
      "OMPL is a free sampling-based motion planning library.")
    (description
      "OMPL is a free sampling-based motion planning library.")
    (license license:bsd-3)))

(define-public moveit-kinematics
  (package
    (name "moveit-kinematics")
    (version "0.9.18")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ros-gbp/moveit-release.git")
               (commit
                 "release/kinetic/moveit_kinematics/0.9.18-1")))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "1djil2kb4898nin1cqps9zqcy0i4zany755k0pqmr37i9kp3mxp7"))))
    (build-system cmake-build-system)
    (native-inputs `(("catkin" ,catkin)))
    (inputs
      `(("moveit-core" ,moveit-core)
        ("pluginlib" ,pluginlib)
        ("eigen" ,eigen)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("roscpp" ,roscpp)
        ("srdfdom" ,srdfdom)
        ("tf" ,tf)
        ("tf-conversions" ,tf-conversions)
        ("urdf" ,urdf)))
    (propagated-inputs
      `(("moveit-core" ,moveit-core)
        ("pluginlib" ,pluginlib)
        ("moveit-ros-planning" ,moveit-ros-planning)
        ("roscpp" ,roscpp)))
    (home-page "http://moveit.ros.org")
    (synopsis
      "Package for all inverse kinematics solvers in MoveIt!")
    (description
      "Package for all inverse kinematics solvers in MoveIt!")
    (license license:bsd-3)))
