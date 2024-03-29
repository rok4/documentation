#!/bin/bash

set -e

ROK4GENERATION_VERSION=develop
ROK4PREGENERATION_VERSION=develop
ROK4COREPERL_VERSION=develop
ROK4COREPYTHON_VERSION=develop
ROK4CORECPP_VERSION=develop
ROK4TOOLS_VERSION=develop
ROK4PYTOOLS_VERSION=develop
ROK4SERVER_VERSION=develop
ROK4DOCKER_VERSION=develop

clone=""
mkdocs=""
doxygen=""
naturaldocs=""
pdoc=""

ARGUMENTS="generation:,docker:,pregeneration:,coreperl:,corepython:,corecpp:,tools:,pytools:,server:,clone,mkdocs,doxygen,naturaldocs,pdoc"
# read arguments
opts=$(getopt \
    --longoptions "${ARGUMENTS}" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)
eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in

        --generation)
            ROK4GENERATION_VERSION=$2
            shift 2
            ;;
        --pregeneration)
            ROK4PREGENERATION_VERSION=$2
            shift 2
            ;;
        --coreperl)
            ROK4COREPERL_VERSION=$2
            shift 2
            ;;
        --corepython)
            ROK4COREPYTHON_VERSION=$2
            shift 2
            ;;
        --corecpp)
            ROK4CORECPP_VERSION=$2
            shift 2
            ;;
        --tools)
            ROK4TOOLS_VERSION=$2
            shift 2
            ;;
        --pytools)
            ROK4PYTOOLS_VERSION=$2
            shift 2
            ;;
        --server)
            ROK4SERVER_VERSION=$2
            shift 2
            ;;
        --docker)
            ROK4DOCKER_VERSION=$2
            shift 2
            ;;

        --clone)
            clone=1
            shift 1
            ;;
        --mkdocs)
            mkdocs=1
            shift 1
            ;;
        --doxygen)
            doxygen=1
            shift 1
            ;;
        --naturaldocs)
            naturaldocs=1
            shift 1
            ;;
        --pdoc)
            pdoc=1
            shift 1
            ;;

        *)
            break
            ;;
    esac
done

export ROK4GENERATION_VERSION
export ROK4PREGENERATION_VERSION
export ROK4COREPERL_VERSION
export ROK4COREPYTHON_VERSION
export ROK4CORECPP_VERSION
export ROK4TOOLS_VERSION
export ROK4PYTOOLS_VERSION
export ROK4SERVER_VERSION
export ROK4DOCKER_VERSION

# Récupération des sources
if [[ ! -z $clone ]]; then
    if [[ -d build/sources ]]; then
        rm -rf build/sources
    fi
    mkdir -p build/sources
    git clone --branch $ROK4GENERATION_VERSION --depth 1 https://github.com/rok4/generation build/sources/generation
    git clone --branch $ROK4PREGENERATION_VERSION --depth 1 https://github.com/rok4/pregeneration build/sources/pregeneration
    git clone --branch $ROK4COREPERL_VERSION --depth 1 https://github.com/rok4/core-perl build/sources/core-perl
    git clone --branch $ROK4COREPYTHON_VERSION --depth 1 https://github.com/rok4/core-python build/sources/core-python
    git clone --branch $ROK4CORECPP_VERSION --depth 1 https://github.com/rok4/core-cpp build/sources/core-cpp
    git clone --branch $ROK4TOOLS_VERSION --depth 1 https://github.com/rok4/tools build/sources/tools
    git clone --branch $ROK4PYTOOLS_VERSION --depth 1 https://github.com/rok4/pytools build/sources/pytools
    git clone --branch $ROK4SERVER_VERSION --depth 1 https://github.com/rok4/server build/sources/server
    git clone --branch $ROK4DOCKER_VERSION --depth 1 https://github.com/rok4/docker build/sources/docker
fi


# Documentation développeur C++
if [[ ! -z $doxygen ]]; then
    mkdir -p build/target/doxygen/fr
    doxygen compilation/doxygen/Doxyfile.fr
    mkdir -p build/target/doxygen/en
    doxygen compilation/doxygen/Doxyfile.en
fi

# Documentation développeur Perl
if [[ ! -z $naturaldocs ]]; then
    mkdir -p build/target/naturaldocs/en/html
    perl ./tools/analyzer.pl build/sources/ build/sources/images/libperlauto
    naturaldocs -r --project compilation/naturaldocs/ \
        --input ./build/sources/ \
        -img ./build/sources/pregeneration/docs/images/ -img ./build/sources/core-perl/docs/images/ -img ./build/sources/images/ -img ./build/sources/generation/docs/images/ \
        --no-auto-group --documented-only \
        --output HTML build/target/naturaldocs/en/html 
fi

# Documentation développeur Python
if [[ ! -z $pdoc ]]; then
    mkdir -p build/target/pdoc/en/html
    cd build/sources/core-python
    VERSION=$ROK4COREPYTHON_VERSION pdoc --force --html --output-dir ../../target/pdoc/en/html rok4
    cd ../../../
fi

# Documentation principale et utilisateur Markdown
if [[ ! -z $mkdocs ]]; then
    mkdir -p build/target/dist/
    cp -r compilation/mkdocs/extras specifications images build/sources/
    cp index.md build/sources/

    envsubst < compilation/mkdocs/devs.md > build/sources/devs.md

    LC_ALL=C.UTF-8 mkdocs build --config-file compilation/mkdocs/mkdocs.yaml
fi

if [[ ! -z $doxygen || ! -z $mkdocs ]]; then
    cp -r build/target/doxygen build/target/dist/
fi

if [[ ! -z $naturaldocs || ! -z $mkdocs ]]; then
    cp -r build/target/naturaldocs build/target/dist/
fi

if [[ ! -z $pdoc || ! -z $mkdocs ]]; then
    cp -r build/target/pdoc build/target/dist/
fi


