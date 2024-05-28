# KiCad Template
KiCad 8 project template with document export automation

For KiCad *Version: 8.99.0-77eaa75db1, release build*

<img src="./exports/renderings/template-top.png" width="45%"/> <img src="./exports/renderings/template-bottom.png" width="45%"/>

Browse the files on [KiCanvas](https://kicanvas.org/?github=https://github.com/cyber-murmel/kicad-template/tree/main/source/template) - by [Stargirl Flowers](https://github.com/theacodes)

## Directory Structure
| directory  | content                                                              |
|------------|----------------------------------------------------------------------|
| source     | KiCad project directories                                            |
| production | fabrication files (Gerber, BOM, placement)                           |
| exports    | schematic and layout plots, board 3D model and renderings            |
| datasheets | component datasheets                                                 |
| assets     | board setups, component 3D models, logos                             |
| scripts    | BOM export plugins, miscellaneous helper scripts for file conversion |
| hooks      | git hooks, for example for automatic documentation export            |

---
✃

## Usage
[TL;DR](README.md#tldr)

Click [![Use this template](https://img.shields.io/badge/-Use_this_template-green.svg)](https://github.com/cyber-murmel/kicad-template/generate) to create a new repository and clone it to your machine.

### Customizing the Template (optional)
If your project consists of multiple designs, which all should adhere to the same design rules, you can modify the [template](source/template/) first, before creating projects based on it.
You can read more about this in the [Customizing the Project](README.md#customizing-the-project-optional) section, since the template is essentially also just a project.

Afterwards commit the changes to your template.
```shell
git add source/template/
git commit -m "customized template"
```

### Creating a Project
Enter the repository, copy the [template](source/template/), rename the source files and change the project name in the files.

```shell
PROJECT_NAME="my-cool-project"

cp --recursive source/template/ source/"${PROJECT_NAME}"/
rename "template" "${PROJECT_NAME}" source/"${PROJECT_NAME}"/*
sed -i -e "s/template/${PROJECT_NAME}/g" source/"${PROJECT_NAME}"/"${PROJECT_NAME}".* Makefile
```

### Customizing the Project (optional)
Start KiCad and open the project you just created.

The template makes use of *Text Variables*. You can edit these in the Schematic or PCB Editor. Go to **File > Schematic Setup > Project > Text Variables** or **File > Board Setup > Text & Graphics > Text Variables** respectively. In there you can change properties like project ID, revision, author and company name. These then automatically get updated throughout all file and changes for example the info box in the corner of each document.

You can also import predefined board setups. In the PCB Editor go to **File > Board Setup** and click *Import Settings from Another Board* in the lower left corner. You can import from on of the [board setups that are part of this repository](assets/board%20setups/) or any other project of yours.
Select which parts to import. Selecting all should be ok in most cases.

### Create Initial Commit for Your Project
It's a good idea to commit all relevant changes to the project, starting with an initial commit .
```shell
git add source/${PROJECT_NAME}/
git commit -m "Initial commit for ${PROJECT_NAME}"
```

## TL;DR
```shell
PROJECT_NAME="my-cool-project"

git clone https://github.com/cyber-murmel/kicad-template.git "${PROJECT_NAME}"
cd "${PROJECT_NAME}"

cp --recursive source/template/ source/"${PROJECT_NAME}"/
rename "template" "${PROJECT_NAME}" source/"${PROJECT_NAME}"/*
sed -i -e "s/template/${PROJECT_NAME}/g" source/"${PROJECT_NAME}"/"${PROJECT_NAME}".* Makefile

git add source/${PROJECT_NAME}/
git commit -m "Initial commit for ${PROJECT_NAME}"
```

✁

---
## Automation
This repository contains a Makefile that automates PDF and Gerber export.

### Requirements
Apart from [KiCad 7](#kicad-version) this requires some additional software.

The Makefile calls a Python script that makes use of [sexptdata](https://pypi.org/project/sexpdata/) to parse KiCad files.
Install [Poetry](https://python-poetry.org/) and run `poetry shell` followed by `poetry install` in the root of this repositoryto set up a virtual environment with the required package(s). To re-enter this environment, simply run `poetry shell` in the root of this repository.

For PDF export you additonally need to install [Poppler](https://poppler.freedesktop.org/).
Gerber export requires [zip](https://infozip.sourceforge.net/).

#### Nix(OS)
If you are using the Nix package manager, you can enter a development environment
with KiCad and all other software by running `nix-shell` in the root of this
repository.

### Export
To export all PDFs and production files, simply run
```shell
make
```
PDFs and production files are exported automatically when you `git commit`, if you have
[Git Hooks](#installing-git-hooks-optional) set up.

### Installing Git Hooks (optional)
The [hooks](hooks) directory contains client-side [git hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).
Currently only the pre-commit hook is used to automatically export plots.

To enable the hooks locally, run the following in the root of the repository.
```shell
git config core.hooksPath ./hooks
```

## KiCad Version
Version information of the KiCad used to generate the files.
```
Application: kicad-cli x86_64 on x86_64

Version: 8.0.2, release build

Libraries:
	wxWidgets 3.2.4
	FreeType 2.13.2
	HarfBuzz 8.4.0
	FontConfig 2.15.0
	libcurl/8.7.1 OpenSSL/3.0.13 zlib/1.3.1 brotli/1.1.0 zstd/1.5.6 libidn2/2.3.7 libpsl/0.21.5 libssh2/1.11.0 nghttp2/1.61.0

Platform: NixOS 23.11 (Tapir), 64 bit, Little endian, wxBase, , wayland

Build Info:
	Date: Jan  1 1980 00:00:00
	wxWidgets: 3.2.4 (wchar_t,wx containers) GTK+ 0.0
	Boost: 1.81.0
	OCC: 7.6.2
	Curl: 8.7.1
	ngspice: 42
	Compiler: GCC 13.2.0 with C++ ABI 1018

Build settings:
	KICAD_USE_EGL=ON
```
