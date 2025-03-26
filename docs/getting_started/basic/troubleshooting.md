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

## Windows No Content in App [¶](\#windows-no-content-in-app "Permalink to this headline")

When using FiftyOne in a notebook or in a web browser in Windows, if launching
the app results in a blank screen, it's possibly due to an issue with the MIME
type settings. When using a browser, while at `localhost:5151` you can check
the Console by opening Developer Tools <kbd>F12</kbd> or under "More Tools"
menu. Once the Developer Tools pop out is open, click the <kbd>Console</kbd>
tab. If you see an error similar to:

??? info "No Content in Jupyter Notebook"
    If using a Jupyter Notebook, you should check using a web browser using the
    same process above to see if the same error is shown.

```txt
Failed to load module script: Expected a JavaScript module script but the
server responded with a MIME type of "text/plain". Strict MIME type checking
is enforced for module scripts per HTML spec.
```

This is likely due to a registry misconfiguration. This can be remedied by
modifying a few keys in the Windows Registry.

!!! danger
    Modifying the Windows Registry can have **serious** consequences if done
    incorrectly. Make sure to back up the registry before making any changes as
    incorrect changes to the registry can cause system instability or even
    render your system inoperable. Proceed with caution and only modify the
    registry if you are confident in what you are doing.

### Modifying Windows Registry [¶](\#modifying-windows-registry "Permalink to this headline")

1. Open the Windows menu and type `regedit` and open the Registry Editor
(requires Admin permissions).

2. In the Registry Editor window, use the location bar to navigate to:

    ```{ .registry .annotate }
    HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.js  # (1)!
    ```

    1. You may need to prepend `COMPUTER\` navigate to
    `COMPUTER\HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.js`

3. Look for the Value Name `Content Type`, this is probably set to `text/plain`
if the app is not rendering content. Change the `Content Type` Value data to
`text/javascript` by double clicking to modify the data.

4. Next, use the location bar to navigate to:

    ```{ .registry .annotate }
    HKEY_CLASSES_ROOT\.js  # (1)!
    ```

    1. You may need to prepend `COMPUTER\` navigate to
    `COMPUTER\HKEY_CLASSES_ROOT\.js`

5. Again, look for the Value Name `Content Type` and update the Value data to
`text/javascript`.

6. Close the Registry Editor, and reboot your computer.

7. After rebooting, try launching the app again and open a browser. If this
was the issue, you should now see the FiftyOne application in your browser.

### References [¶](\#references "Permalink to this headline")

Resources used to resolve this issue.

- [Golang GitHub issue](https://github.com/golang/go/issues/32350#issuecomment-635859542)
(recommend reviewing entire thread).

- [Python Bugs](https://bugs.python.org/issue43975)

- [Mozilla MIME Types](https://developer.mozilla.org/en-US/docs/Web/HTTP/MIME_types#textjavascript)
