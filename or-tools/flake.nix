{
  description = "Google or-tools flake";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    package = {
      url = github:google/or-tools;
      flake = false;
    };

    protobuf = {
      url = github:protocolbuffers/protobuf;
      flake = false;
    };

    pybind11_protobuf = {
      url = github:pybind/pybind11_protobuf;
      flake = false;
      #url = "../pybind11-protobuf";
    };

    #pybind11_protobuf = {
    #  url = github:pybind/pybind11_protobuf;
    #  flake = false;
    #};

    # dependency1.url = "../dependency";
    # dependency2.url = github:user/program;
    # dependency3.url = "https://git.com/repo";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flakeUtils,
    package,
    protobuf,
    pybind11_protobuf,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
  in
    flakeUtils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      pname = "or-tools";
      #version = "9.4";
      #version = package.version;
      version = "";
      src = package;
      pkgPython = pkgs.python311;
      # protobufPkg = protobuf.packages.${system}.default;
      # pybindProtoPkg = pybind11_protobuf.packages.${system}.default;
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit pname version system src;

          # patches = with pkgs; [
          #   # Disable test that requires external input: https://github.com/google/or-tools/issues/3429
          #   (fetchpatch {
          #     url = "https://github.com/google/or-tools/commit/7072ae92ec204afcbfce17d5360a5884c136ce90.patch";
          #     hash = "sha256-iWE+atp308q7pC1L1FD6sK8LvWchZ3ofxvXssguozbM=";
          #   })

          #   # Fix test that broke in parallel builds: https://github.com/google/or-tools/issues/3461
          #   (fetchpatch {
          #     url = "https://github.com/google/or-tools/commit/a26602f24781e7bfcc39612568aa9f4010bb9736.patch";
          #     hash = "sha256-gM0rW0xRXMYaCwltPK0ih5mdo3HtX6mKltJDHe4gbLc=";
          #   })

          #   # Backport fix in cmake test configuration where pip installs newer version from PyPi over local build,
          #   #  breaking checkPhase: https://github.com/google/or-tools/issues/3260
          #   (fetchpatch {
          #     url = "https://github.com/google/or-tools/commit/edd1544375bd55f79168db315151a48faa548fa0.patch";
          #     hash = "sha256-S//1YM3IoRCp3Ghg8zMF0XXgIpVmaw4gH8cVb9eUbqM=";
          #   })

          #   # Don't use non-existent member of string_view. Partial patch from commit
          #   # https://github.com/google/or-tools/commit/c5a2fa1eb673bf652cb9ad4f5049d054b8166e17.patch
          #   ./fix-stringview-compile.patch
          # ];

          # # or-tools normally attempts to build Protobuf for the build platform when
          # # cross-compiling. Instead, just tell it where to find protoc.
          postPatch = ''
            echo "set(PROTOC_PRG $(type -p protoc))" > cmake/host.cmake
          '';

          CMAKE_MAKE_PROGRAM = "make -j $NIX_BUILD_CORES";

          cmakeFlags = with pkgs;
            [
              "-DBUILD_DEPS=OFF"
              "-DBUILD_PYTHON=ON"
              "-DBUILD_pybind11=OFF"
              "-DFETCH_PYTHON_DEPS=OFF"
              "-DUSE_GLPK=ON"
              "-DUSE_SCIP=OFF"
              "-DPython3_EXECUTABLE=${pkgPython.pythonOnBuildForHost.interpreter}"
              #"-DBUILD_pybind11_protobuf=${pybind11_protobuf}"
              #"-DBUILD_pybind11_protobuf=OFF"
              "-Dpybind11_protobuf_DIR=${pybind11_protobuf}"
            ]
            ++ lib.optionals stdenv.isDarwin ["-DCMAKE_MACOSX_RPATH=OFF"];

          propagatedBuildInputs = with pkgs; [
            abseil-cpp
            (pkgPython.pkgs.protobuf.override {protobuf = inputs.protobuf;})
            #(pkgPython.pkgs.protobuf.override {protobuf = protobufPkg;})
            pkgPython.pkgs.numpy

            #inputs.protobuf
            #protobufPkg
            #protobuf
          ];

          nativeCheckInputs = with pkgs; [
            pkgPython.pkgs.matplotlib
            pkgPython.pkgs.pandas
            pkgPython.pkgs.virtualenv
          ];

          buildInputs = with pkgs; [
            bzip2
            cbc
            eigen
            glpk
            pkgPython.pkgs.absl-py
            pkgPython.pkgs.pybind11
            pkgPython.pkgs.setuptools
            pkgPython.pkgs.wheel
            re2
            zlib
          ];

          nativeBuildInputs = with pkgs;
            [
              cmake
              ensureNewerSourcesForZipFilesHook
              pkg-config
              pkgPython.pythonOnBuildForHost
              swig4
              unzip

              #pybind11_protobuf
              #pybindProtoPkg
              # pybind11_protobuf.packages.${system}.default
            ]
            ++ (with pkgPython.pythonOnBuildForHost.pkgs; [
              pip
              mypy-protobuf
            ]);

          doCheck = true;

          # This extra configure step prevents the installer from littering
          # $out/bin with sample programs that only really function as tests,
          # and disables the upstream installation of a zipped Python egg that
          # can’t be imported with our Python setup.
          installPhase = ''
            cmake . -DBUILD_EXAMPLES=OFF -DBUILD_PYTHON=OFF -DBUILD_SAMPLES=OFF
            cmake --install .
            pip install --prefix="$python" python/
          '';

          outputs = ["out" "python"];

          meta = with lib; {
            homepage = "https://github.com/google/or-tools";
            license = licenses.asl20;
            description = ''
              Google's software suite for combinatorial optimization.
            '';
            platforms = with platforms; linux;
          };
        };
      };
    });
}
