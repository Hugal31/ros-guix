(define-module (fcl)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix build-system cmake)
  #:use-module (guix git-download)
  )

(define-public fcl
  (package
   (name "fcl")
   (version "0.5.0")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/flexible-collision-library/fcl")
           (commit "7075caf32ddcd5825ff67303902e3db7664a407a")))
     (file-name (git-file-name name version))
     (sha256
      (base32
       "050pmvwmnv9a8y03hakyvvi6z0hccv7p3qclnqq1s8csh27m6bfb"))))
   (build-system cmake-build-system)
   (home-page "https://github.com/flexible-collision-library/fcl")
   (synopsis "Flexible Collision Library")
   (description
    "FCL is a library for performing three types of proximity queries on a pair of geometric models composed of triangles.")
   (license license:bsd-3)))
