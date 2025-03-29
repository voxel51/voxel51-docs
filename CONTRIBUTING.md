# Contributing to FiftyOne Technical Documentation

FiftyOne is open source and community contributions are welcome!

If you have not already, we recommend browsing currently
[active issues](https://github.com/voxel51/voxel51-docs/issues) to
get a sense of what is planned for FiftyOne. We have marked some issues with
a `good first doc`
[label](https://github.com/voxel51/voxel51-docs/labels/good%20first%20doc)
if you are looking for a good place to start.

The procedure for editing the doc can be as simple as:

1. Fork the repo
1. Edit the page in Github
1. Commit the change in your fork
1. File a pull request in this repo

Someone from our team will review and as soon as it is
merged your change will go live!

If you would like to take on a more substantial documentation task,
follow the steps below. If you need help please
reach out to us in our #docs channel on the
[Voxel51 Discord Server](https://community.voxel51.com/).

Don't be intimidated by the procedures outlined below.
They are not dogmatic and are only meant to help guide
development as the project and number of contributors grow.

## Contribution Process

### GitHub Issues

The FiftyOne documentation contribution process generally starts with filing a
[GitHub issue](https://github.com/voxel51/voxel51-docs/issues).

FiftyOne defines these categories of issues:

- bug reports
- documentation
- feature requests

Small corrections (such as typos or other minor improvements) do not need to have a
corresponding issue.

We recommend awaiting feedback from a FiftyOne
maintainer or community member before proceeding to implement a feature or
patch. This is particularly important for significant changes. During
issue triage, we will add the label `needs discussion`.

### Pull Requests

After you have agreed upon the content and work plan with a Voxel51 team member,
the next step is to introduce your changes
(see [developer guide](#developer-guide))
as a pull request against the FiftyOne repository.

Steps to make a pull request:

- Fork the [https://github.com/voxel51/voxel51-docs](https://github.com/voxel51/voxel51-docs) repo
- Implement your feature as a branch off of the `main` branch
- Create a pull request into the `main` branch of
  [https://github.com/voxel51/voxel51-docs](https://github.com/voxel51/voxel51-docs)

Docs are built and deployed on merge without a formal "release date".
When your PR is merged and the build completes,
you will be able to see your changes on the production documentation site.

## Contribution Guidelines

Here are some general guidelines for developing new features and patches for
FiftyOne:

## Developer Guide

### Installation

You will need to have Python installed on your machine.
Install the requirements

```shell
pip install -r requirements.txt
```

If you plan to build the TypeScript documentation, you
will need to install the Yarn dependencies

```shell
yarn install
```

If you plan to build the whole site, you
will need to use [`build.sh`](./build.sh).

Before committing code,
enable pre-commit hooks.

```shell
make hooks
```

### General Technical Documentation

We use [Mkdocs](https://www.mkdocs.org/) with
[Material for Mkdocs](https://squidfunk.github.io/mkdocs-material/)
to build our documentation.
All content, except Jupyter Notebooks, should be in Markdown.
Jupyter Notebooks should be in standard notebook format.

Images, should be contributed in
[WebP format](https://developers.google.com/speed/webp)
and no wider than 1600px.
Exceptions can be made to the formatting given sufficient reason.
Most browsers support WebP and several graphics programs
and libraries can export to WebP.

### Python API

The [FiftyOne API](https://voxel51.com/docs/fiftyone/user_guide/basics.html)
is implemented in Python and the source code lives in
[fiftyone/fiftyone](https://github.com/voxel51/fiftyone/tree/develop/fiftyone).
`setup.py` contains the Python versions for the project.

Changes to the Python API docs must be made in the Fiftyone Python code.
You will need to make a pull request on the [FiftyOne repo](https://github.com/voxel51/fiftyone).
Please see our
[fiftyone contributing guide](https://github.com/voxel51/fiftyone/blob/develop/CONTRIBUTING.md)
for more information.

### FiftyOne App

The [FiftyOne App](https://voxel51.com/docs/fiftyone/user_guide/app.html)
is an Electron App implemented in TypeScript. The source code lives in
[fiftyone/app](https://github.com/voxel51/fiftyone/tree/develop/app).

All TypeScript API documentation changes must be made in the FiftyOne repo.
Please see our
[fiftyone app contributing guide](https://github.com/voxel51/fiftyone/blob/develop/app/CONTRIBUTING.md)
for more information.

### Linting

We use [asdf][asdf] to manage packages (at pinned versions)
across platforms (macOS, Linux).
This ensures that we have deterministic behavior amongst the contributors,
no matter where our code runs (locally, GitHub Actions, Google Cloud Build).

By using the same tools locally as in our CI/CD, we benefit from shifting left
and reduce the development feedback loop.

Tools

- [asdf][asdf]
- [pre-commit][pre-commit]
- [black][black]

To ease the adoption (and simplify CI/CD runs) we can call make targets.
See [./Makefile](./Makefile).

### Tooling Initialization

1. Install asdf.
   See
   [asdf getting started](https://asdf-vm.com/guide/getting-started.html).
1. Install the asdf managed packages (at a specific version)

    ```shell
    make asdf
    ```

1. Install the repo's pre-commit hooks

    ```shell
    make hooks
    ```

1. Run pre-commit

    ```shell
    pre-commit run -a
    ```

    or

    ```shell
    make pre-commit
    ```

## Sections and functionality still to be written

1. More specifics on image formats

[asdf]: https://asdf-vm.com/
[pre-commit]: https://pre-commit.com/
[black]: https://github.com/psf/black
