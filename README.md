Use this to initialize your UE4 game(or anything) project for git.
ue4-project-git-initializer.sh version alpha 0.0.1:
Usage:
    bash ue4-project-git-initializer.sh --ue4-root-dir=$(UE4 Root Folder) --git-repo-url=$(Git Origin Remote URL For Your Project) --project-file=$(PROJECT_FILE)
    generate everything needed to get started.
    bash ue4-project-git-initializer.sh --ue4-root-dir=$(UE4 Root Folder) --project-file=$(PROJECT_FILE)
    generate Makefile and other ide project files.
    bash ue4-project-git-initializer.sh --project-file=$(PROJECT_FILE)
just to create the git repo and manually do the previous steps your self:
    touch .gitignore - to include all files that are generated( not recomended) and do not use the embeded .gitignore file
    touch Makefile - to stop the creation of an initial Makefile that is run
