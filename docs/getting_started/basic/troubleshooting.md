# Install Troubleshooting [¶](\#install-troubleshooting "Permalink to this headline")

This page lists common issues encountered when installing FiftyOne and possible
solutions. If you encounter an issue that this page doesn’t help you resolve,
feel free to
[open an issue on GitHub](https://github.com/voxel51/fiftyone/issues/new?labels=bug&template=installation_issue_template.md&title=%5BSETUP-BUG%5D)
or [contact us on Discord](https://community.voxel51.com).

Note

Most installation issues can be fixed by upgrading some packages and then
rerunning the FiftyOne install. So, try this first before reading on:

```python
pip install --upgrade pip setuptools wheel build
pip install fiftyone

```

## Python/pip incompatibilities [¶](\#python-pip-incompatibilities "Permalink to this headline")

### “No matching distribution found” [¶](\#no-matching-distribution-found "Permalink to this headline")

If you attempt to install FiftyOne with a version of Python or pip that is too
old, you may encounter errors like these:

```python
ERROR: Could not find a version that satisfies the requirement fiftyone (from versions: none)
ERROR: No matching distribution found for fiftyone

```

```python
Could not find a version that satisfies the requirement fiftyone-brain (from versions: )
No matching distribution found for fiftyone-brain

```

```python
fiftyone requires Python '>=3.9' but the running Python is 3.4.10

```

To resolve this, you will need to use Python 3.9 or newer, and pip 19.3 or
newer. See the [installation guide](install.md#installing-fiftyone) for details. If
you have installed a suitable version of Python in a virtual environment and
still encounter this error, ensure that the virtual environment is activated.
See the
[virtual environment setup guide](virtualenv.md) for more details.

Note

FiftyOne does not support 32-bit platforms.

### “Package ‘fiftyone’ requires a different Python” [¶](\#package-fiftyone-requires-a-different-python "Permalink to this headline")

This error occurs when attempting to install FiftyOne with an unsupported
Python version (either too old or too new). See the
[installation guide](install.md#install-prereqs) for details on which versions of
Python are supported by FiftyOne.

If you have multiple Python installations, you may be using `pip` from an
incompatible Python installation. Run `pip --version` to see which Python
version `pip` is using. If you see an unsupported or unexpected Python version
reported, there are several possible causes, including:

- You may not have activated a virtual environment in your current shell. Refer
to the [virtual environment setup guide](virtualenv.md) for details.

- If you are intentionally using your system Python installation instead of a
virtual environment, your system-wide `pip` may use an unsupported Python
version. For instance, on some Linux systems, `pip` uses Python 2, and `pip3`
uses Python 3. If this is the case, try installing FiftyOne with `pip3`
instead of `pip`.

- You may not have a compatible Python version installed. See the
[installation guide](install.md#install-prereqs) for details.


### “No module named skbuild” [¶](\#no-module-named-skbuild "Permalink to this headline")

On Linux, this error can occur when attempting to install OpenCV with an old
pip version. To fix this, upgrade pip. See the
[installation guide](install.md#installing-fiftyone) for instructions, or the
[opencv-python FAQ](https://pypi.org/project/opencv-python-headless/) for
more details.

## Videos do not load in the App [¶](\#videos-do-not-load-in-the-app "Permalink to this headline")

You need to install [FFmpeg](https://ffmpeg.org) in order to work with video
datasets:

Without FFmpeg installed, videos may appear in the App, but they will not be
rendered with the correct aspect ratio and thus label overlays will not be
positioned correctly.

## IPython installation [¶](\#ipython-installation "Permalink to this headline")

If you are using IPython and a virtual environment for FiftyOne, IPython must
be installed in the virtual environment, per the
[installation guide](install.md#installing-extras). If you attempt to use a
system-wide IPython installation in a virtual environment with FiftyOne, you
may encounter errors such as:

```python
.../IPython/core/interactiveshell.py:935: UserWarning: Attempting to work in a virtualenv. If you encounter problems, please install IPython inside the virtualenv.

```

```python
File ".../fiftyone/core/../_service_main.py", line 29, in <module>
    import psutil
ModuleNotFoundError: No module named 'psutil'

```

```python
ServerSelectionTimeoutError: localhost:27017: [Errno 111] Connection refused

```

To resolve this, install IPython in your active virtual environment (see the
[virtual environment guide](virtualenv.md#virtualenv-guide) for more information):

```python
pip install ipython

```

## Import and database issues [¶](\#import-and-database-issues "Permalink to this headline")

FiftyOne includes a `fiftyone-db` package wheel for your operating system and
hardware. If you have not
[configured your own database connection](../../fiftyone_concepts/config.md#configuring-mongodb-connection),
then FiftyOne’s database service will attempt to start up on import using the
MongoDB distribution provided by `fiftyone-db`. If the database fails to start,
importing `fiftyone` will result in exceptions being raised.

## Downgrading to old versions [¶](\#downgrading-to-old-versions "Permalink to this headline")

The [fiftyone migrate](../../cli/index.md#cli-fiftyone-migrate) command was introduced in
FiftyOne v0.7.3. If you would like to downgrade from a FiftyOne version
prior to v0.7.3 (to a yet older version), then you will first need to
[upgrade](install.md#upgrading-fiftyone) to v0.7.3 or later and then
[downgrade](install.md#downgrading-fiftyone):

```python
# The version that you wish to downgrade to
VERSION=0.7.0

pip install fiftyone==0.7.3
fiftyone migrate --all -v $VERSION
pip install fiftyone==$VERSION

```

To install a FiftyOne version prior to v0.7.0, you must add `--index`:

```python
pip install --index https://pypi.voxel51.com fiftyone==<version>

```

## Database exits [¶](\#database-exits "Permalink to this headline")

On some UNIX systems, the default open file limit setting is too small for
FiftyOne’s MongoDB connection. The database service will exit in this case.
Running `ulimit -n 64000` should resolve the issue. 64,000 is the recommended
open file limit. MongoDB has full documentation on the issue
[here](https://docs.mongodb.com/manual/reference/ulimit/).

### Troubleshooting Linux imports [¶](\#troubleshooting-linux-imports "Permalink to this headline")

`fiftyone-db` officially supports Amazon Linux 2 and 2023, Debian 9+
(x86\_64 only), Ubuntu 18.04+, and RHEL/CentOS 7+ Linux distributions. The
correct MongoDB build is downloaded and installed while building the package
wheel on your machine.

If a suitable MongoDB build is not available or otherwise does not
work in your environment, you may encounter a `FiftyOneConfigError`.

If you have output similar to the below, you may just need to install
`libssl` packages.

```python
Subprocess ['.../site-packages/fiftyone/db/bin/mongod', ...] exited with error 127:
.../site-packages/fiftyone/db/bin/mongod: error while loading shared libraries:
  libcrypto.so.1.1: cannot open shared object file: No such file or directory

```

On Ubuntu, `libssl` packages can be install with the following command:

```python
sudo apt install libssl-dev

```

If you still face issues with imports, you can follow
[these instructions](../../fiftyone_concepts/config.md#configuring-mongodb-connection) to configure
FiftyOne to use a MongoDB instance that you have installed yourself.

### Troubleshooting Windows imports [¶](\#troubleshooting-windows-imports "Permalink to this headline")

If your encounter a `psutil.NoSuchProcessExists` exists when importing
`fiftyone`, you are likely missing the C++ libraries MongoDB requires.

```python
psutil.NoSuchProcess: psutil.NoSuchProcess process no longer exists (pid=XXXX)

```

Downloading and installing the Microsoft Visual C++ Redistributable from this
[page](https://support.microsoft.com/en-us/topic/the-latest-supported-visual-c-downloads-2647da03-1eea-4433-9aff-95f26a218cc0)
should resolve the issue. Specifically, you will want to download the
`vc_redist.x64.exe` redistributable.

