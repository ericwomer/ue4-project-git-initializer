#!/bin/bash

# Root path to your UE4 clone, set via the command line option --ue4-root=
UE4_ROOT_DIR=""

# Your projects origin url, set via the command line option --origin=
GIT_REPO_URL=""

# Your projects .uproject file, set up with command line option --project-name=
PROJECT_FILE_EXT="uproject"
PROJECT_FILE_NAME=""
PROJECT_ROOT_PATH="${PWD}"
PROJECT_FILE=""
#PROJECT_FILE="${PROJECT_ROOT_PATH}/${PROJECT_FILE_NAME}.${PROJECT_FILE_EXT}"

# Parameter list that is parsed later on.
PARAMS="$@"

# Makesure to test if these files exist before deciding on writing them
OVERWRITE_MAKEFILE=true
OVERWRITE_GITIGNORE=true

if [ ! -d .git ]; then
  INITIALIZE_EMPTY_GIT=true
else
  INITIALIZE_EMPTY_GIT=false
fi

INITIALIZE_EMTY_GIT_NO_SET_ORIGIN=false

SCRIPT_NAME=`basename "$0"`

# Script usage line, subject to change.
usage() {
printf "%s version alpha 0.0.1:
Usage:
\tbash %s --ue4-root-dir=\$(UE4_ROOT_DIR) --git-repo-url=\$(GIT_ORIGIN_URL) --project=\$(PROJECT_NAME)
\tgenerate everything needed to get started.
\tbash %s --ue4-root-dir=\$(UE4_ROOT_DIR) --project=\$(PROJECT_NAME) --no-origin-url
\tgenerate Makefile and other ide project files.
\tbash %s --project=\$(PROJECT_NAME) --no-origin-url
just to create the git repo and manually do the previous steps your self:
\ttouch .gitignore - to include all files that are generated( not recomended) and do not use the embeded .gitignore file
\ttouch Makefile - to stop the creation of an initial Makefile that is run
\t--project=\$(PROJECT_NAME) and (--no-origin-url or --git-repo-url=\$(GIT_ORIGIN_URL)) are manditory.
" $SCRIPT_NAME $SCRIPT_NAME $SCRIPT_NAME $SCRIPT_NAME
exit 0
}

# Write initial Makefile
function writeMakefile() {
printf "TARGETS = configure

UNREALROOTPATH = ${UE4_ROOT_DIR}
PROJECTBUILD = mono \$(UNREALROOTPATH)/Engine/Binaries/DotNET/UnrealBuildTool.exe
GAMEPROJECTFILE = ${PROJECT_FILE}

all: configure

configure:
\txbuild /property:Configuration=Development /property:TargetFrameworkVersion=v4.5 /verbosity:quiet /nologo \$(UNREALROOTPATH)/Engine/Source/Programs/UnrealBuildTool/UnrealBuildTool.csproj
\t\$(PROJECTBUILD) -makefile -kdevelopfile -qmakefile -cmakefile -codelitefile -project=\"\\\\\"\$(GAMEPROJECTFILE)\\\\\"\" -game -engine
" > Makefile
}

# Write the .gitignore file
function writeGitignore() {
printf "
#
# This file tells Git about engine files that never really belong in source control.  They are usually build products, log
# files and intermediate files generated from a compiler or the engine runtime.
#
#
# NOTE:
#  Paths that start with / match paths relative to the root (where the .gitignore file is)
#  Paths that end with / will match a folder and all files under it (but not a regular file with no extension)
#  Use * for wildcards.  Wildcards stop at path separators
#  Use ** for a wildcard that spans path separators
#  Paths in this file should use forward slash characters, not back slashes
#  Use \ to escape special characters like ! and #
#  Use ! to negate a previous pattern.  But it does not work if the parent sub-folder was masked out already.
#
# Ignore all files by default, but scan all directories
*
!*/

# C/C++ source files
!*.c
!*.cc
!*.cpp
!*.cpp.template
!*.h
!*.h.template
!*.hpp
!*.inl
!*.inc
!*.m
!*.mm
!*.rc
!*.def
!*.exp
!*.manifest

# Java source files
!*.java
!*.java.template

# C# source files
!*.cs
!*.cs.template
!*.aspx
!*.resx

# Shader formats
!*.usf
!*.hlsl
!*.glsl

# Text files
!*.txt
!*.md

# Script files
!*.bat
!*.sh
!*.pl
!*.py
!*.js
!*.command

# Other configuration and markup files
!*.ini
!*.json
!*.tps
!*.xml
!*.xaml
!*.uproject
!*.uplugin
!*.html
!*.html.template
!*.css
!*.udn
!*.config
!*.version
!.git*

# Projects and makefiles
!*.cmake
!*.mk
!*.dsp
!*.dsw
!*.csproj
!*.vcproj
!*.vcxproj
!*.vcxproj.filters
!*.sln
!*.xcodeproj
!*.xcconfig
!*.vsprops
!*.snippet
!Makefile
!Makefile.*
!Settings.settings

# Specific names
!README
!AUTHORS
!LICENSE
!FAQ
!VERSION
!ChangeLog

# For projects do not ignore files under the Content/ folder.
!*.uasset
!*.umap

# Ignore Unix backup files
*~

# Exceptions
/*.sln
/*.xcodeproj
/Makefile
/CMakeLists.txt
*.target.xml
*.exe.config
*.user
*.pro
*.pri
/.kdev4/
/.codelite/
/.clang/

# Ignore content folders
# Content/ you can use gits lfs if applicable, or have some other method or repo to supply your Content for you games

# Ignore DDC
/DerivedDataCache/**

# Ignore intermediate folders
Intermediate/
obj/

# Ignore any saved local files
Saved/

# Explcitly ignore Mac DS_Store files, regardless of where they are
.DS_Store

# Explcitly ignore this script
%s
" $SCRIPT_NAME  > .gitignore
}

for i in $PARAMS
do
case $i in
    -h|--help)
    usage
    shift # past argument
    ;;
    --ue4-root-dir=*)
    UE4_ROOT_DIR="${i#*=}"

    if [ ! -d "$UE4_ROOT_DIR" ]; then
      printf "\033[31m%s \n\033[0m" "ERROR! You must set a valid directory path for UE4"
      exit 1
    fi

    shift # past argument
    ;;
    --git-repo-url=*)
    GIT_REPO_URL="${i#*=}"
    INITIALIZE_EMTY_GIT=true
    shift # past argument
    ;;
    --no-origin-url)
    GIT_REPO_URL=""
    INITIALIZE_EMTY_GIT=true
    INITIALIZE_EMTY_GIT_NO_SET_ORIGIN=true
    shift
    ;;
    --project=*)
    PROJECT_FILE_NAME="${i#*=}"

    if [ ! -f "$PROJECT_FILE_NAME.$PROJECT_FILE_EXT" ]; then
      printf "\033[31m%s \n\033[0m" "ERROR! You must set a valid project file name"
      exit 1
    fi

    shift # shift past argument
    ;;
    *)
    printf "\033[31m%s: %s \n\033[0m" "Unknown Option" "${i}"
    exit 1
    ;;
  esac
done

if [ -z "$PROJECT_FILE_NAME" ]; then
  printf "\033[31m%s \n\033[0m" "ERROR! You must set the project name when running this script"
  usage
  exit 1
else
  PROJECT_FILE="${PROJECT_ROOT_PATH}/${PROJECT_FILE_NAME}.${PROJECT_FILE_EXT}"
fi

if [ ${OVERWRITE_MAKEFILE} ]; then
  if [ ! -f Makefile ]; then
    echo "Writing Makefile" ; writeMakefile
  else
    while true; do
      read -p "Are you sure you wan't to overwrite the Makefile? [y/n]" CONT
      case $CONT in
        [yY]) echo "Writing Makefile" ; writeMakefile ; break;;
        [nN]) echo "Skip writing Makefile"; break ;;
        *) printf "\033[31m%s \n\033[0m" "invalid input" ;;
      esac
    done
  fi
fi

if [ ${OVERWRITE_GITIGNORE} ]; then
  if [ ! -f .gitignore ]; then
    echo "Writing .gitignore" ; writeGitignore
  else
    while true; do
      read -p "Are you sure you want to overwirte .gitignore? [y/n]" CONT
      case $CONT in
        [yY]) echo "Writing .gitignore" ; writeGitignore ; break ;;
        [nN]) echo "Skip writing .gitignore" ; break ;;
        *) printf "\033[31m%s \n\033[0m" "invalid input" ;;
      esac
    done
  fi
fi

if [[ ! -d .git && ( $INITIALIZE_EMTY_GIT || $INITIALIZE_EMTY_GIT_NO_SET_ORIGIN) ]]; then
  git init
  git add -A
  git commit -a -m "Project Git Repositary Initialization"
  if [[ ! -z "$GIT_REPO_URL" || -z $INITIALIZE_EMTY_GIT_NO_SET_ORIGIN ]]; then
    git remote add origin "$GIT_REPO_URL"
  else
    printf "\033[1;33m%s \n\033[0m" "Warning! Not setting remote origin url"
  fi
else
  printf "\033[1;33m%s \n\033[0m" "Warning! Not initializing empty git remote as
.git directory exists or --git-repo-url was not set or was empty."
fi
