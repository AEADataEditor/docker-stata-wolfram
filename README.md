# A Stata + Wolfram Engine Docker Project

We demonstrate how you can combine Stata with Wolfram Engine into a single Docker image.

Note that this could also include installing Pandoc or LaTeX, if needed, for Stata.

## Setting up

- Edit the [`init.config.txt`](init.config.txt) to have the desired values for the Docker image you will create:

```{bash}
VERSION=17
# the TAG can be anything, but could be today's date
TAG=$(date +%F) 
MYHUBID=larsvilhuber
MYIMG=${PWD##*/}
STATALIC=/path/to/stata.lic
```

where

- `VERSION` is the Stata version you want to use (this might be ignored right now)
- `TAG` is the Docker tag you will be using - could be "latest", could be a specific name. Has to be lower-case.
- `MYHUBID` is presumably your Docker login
- `MYIMG` is the name you want to give the Docker image you are creating. By default, it presumes that it will be the same name as the Git repository.
- `STATALIC`  is the path to a valid Stata license file (for instance, as installed on your laptop)

- Edit the [`Dockerfile`](Dockerfile). The primary configuration parameters are at the top:

```{Dockerfile}
ARG SRCVERSION=17
ARG SRCTAG=2022-01-17
ARG SRCHUBID=dataeditors
ARG WOLFRAMVERSION=latest
```

where 

- `SRCVERSION` is the Stata version you want to use 
- `SRCTAG` is the tag of the Stata version you want to use as an input
- `SRCHUBID` is where the Stata image comes from - should probably not be modified, but you could use your own.
- `WOLFRAMVERSION` is used to pin the `wolframresearch/wolframengine:WOLFRAMVERSION` versioned image. Adjust as necessary (e.g., "latest", "14.3")

- Finally, edit the [`setup.do`](setup.do) file, which will install any Stata packages into the image.

## Building

Use `build.sh (NAME OF STATA LICENSE FILE)`, e.g.

```{bash}
./build.sh 
```

## Activating Wolfram Engine

On first use, you need to activate Wolfram Engine with your Wolfram ID credentials. Use the activation script:

```{bash}
./activate_wolfram.sh
```

You will be prompted to enter your Wolfram ID and password. The activation will be saved to `$HOME/.WolframEngine/Licensing` on your host machine and will be automatically mounted in future runs.

**Note:** You need a (free) Wolfram Engine developer license. Sign up at https://www.wolfram.com/developer-license

## Running

You also need the Stata license for running it all. For convenience, use the `run.sh` script:

```{bash}
./run.sh 
```

The run script automatically:
- Mounts your Stata license file
- Mounts your Wolfram Engine licensing directory (from `$HOME/.WolframEngine/Licensing`)
- Maps the code and data directories
