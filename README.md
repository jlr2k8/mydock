# MyDock (DRAFT)

## Intro
MyDock is a bash based application to build and host Docker environments locally. It includes official 'joshlrogers'
Docker repo source files, an example Apache/PHP/MySQL application and a directory for your custom projects. Within a
few steps, you can create and start up local development environments. Your PHP/Apache web application mount your
codebases' working copies so you can see live changes as you develop your web app.

## Getting Started

### Requirements

### Application architecture/overview

### Installation

### Usage

#### Full Environment Cleanup:
The following commands will blow away all containers, images and volumes:

1) Stop and remove all containers:

``docker rm $(docker ps -aq) --force``

2) Remove all associated images:

``docker rmi $(docker images -q) --force``

3) Remove all volumes:

``docker volume rm $(docker volume ls -q) --force``

## Projects

### Official joshlrogers repositories

### Example local Apache/MySQL/PHP project

### Your custom projects