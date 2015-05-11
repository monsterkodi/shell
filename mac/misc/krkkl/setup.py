'''
    To build run 'python setup.py py2app' on the command line
'''

from setuptools import setup
setup(
    plugin=["Saver.py"],
    setup_requires=["py2app",
                    "pyobjc-framework-Cocoa",
                    "pyobjc-framework-ScreenSaver"],
    options=dict(
        py2app=dict(
            resources=["thumbnail.png", "thumbnail@2x.png"],
            extension=".saver",
            plist = dict(
                CFBundleName = 'Krkkl',
                NSPrincipalClass = 'Saver',
            )
        )
    )
)

