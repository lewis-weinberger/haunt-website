;;; -*- coding: utf-8 -*-
;;; Copyright © 2020 Lewis Weinberger
;;;
;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License as
;;; published by the Free Software Foundation; either version 3 of the
;;; License, or (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see
;;; <http://www.gnu.org/licenses/>.

(use-modules (haunt builder blog)
             (haunt builder assets)
             (haunt post)
             (haunt site)
             (haunt config)
             (useful))

;; Static "Home"
(define home-page
  (static-page
    "Home"
    "index.html"
    `(,(centered-image "images/mainframe_256x256.gif"))))

;; Static "About" page
(define about-page
  (static-page
    "About"
    "about.html"
    `((h1 "About")
      (p "This is the personal website of Lewis Weinberger."
         " I am currently an astrophysics PhD student at the University of "
         "Cambridge's "
         ,(link* "Institute of Astronomy"
                 "https://www.ast.cam.ac.uk/")
         ". My research so far has focused on the "
         "inter-galactic medium (IGM) — the stuff "
         (i "in-between")
         " galaxies — in particular how this medium evolved"
         " alongside galaxies in the early Universe.")
      (br)
      (p " A lot of my research makes use of High "
         "Performance Computing (HPC), running calculations on "
         ,(link* "supercomputers"
                "https://www.hpc.cam.ac.uk/")
         ". Outside of my PhD work, I'm a computerphile — "
         "I enjoy learning about and using programming languages "
         "and paradigms beyond scientific computing. (Pronouns: "
         (i "he, him, his")
	 ").")
      (br)
      ,(centered-image "images/profile.png")
      (br)
      (p "This site was written in the LISP dialect Scheme (GNU Guile, version "
         ,(version)
         ") and built with the Haunt library (version "
         ,%haunt-version
         ") on "
         ,(strftime "%c" (localtime (current-time)))
         ". The source code can be found on "
         ,(link* "GitHub"
                "https://github.com/lewis-weinberger/haunt-website")
         ". Under the hood it was heavily inspired by David Thompson's website "
         ,(link* "dthompson.us" "https://dthompson.us/")
         ".")
      (br)
      (h2 "Contact Info")
      (p "lewis.weinberger[at]ast.cam.ac.uk"))))

;; Collection of miscellaneous posts
(define %misc
  `(("Recent Posts" "misc.html" ,misc-posts)))

;; Collection of research-related posts
(define %research
  `(("Published Work" "research.html" ,research-posts)))

;; Build site
(site #:title
      "Lewis Weinberger's Homepage"
      #:domain
      "lewis-weinberger.github.io"
      #:default-metadata
      '((author . "Lewis Weinberger"))
      #:readers
      (list commonmark-reader*)
      #:builders
      (list (blog #:theme default-theme #:collections %misc)
            (blog #:theme default-theme #:collections %research)
            home-page
            about-page
	        (static-directory "css")
            (static-directory "images")))
