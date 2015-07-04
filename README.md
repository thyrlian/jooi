# jooi (Junit Output of Infer)
Convert the results of [Infer](http://fbinfer.com/) (static analyzer by Facebook) to JUnit format results.

## Setup
* Have Ruby installed;
* Have nokogiri gem installed (if not, run `gem install nokogiri`);

## Jenkins Configure
* **Build** -> **Execute shell** -> **Command**
```
#!/usr/bin/env bash
#
# Supported build systems by Infer:
#   http://fbinfer.com/docs/analyzing-apps-or-projects.html
# Example analyze commands for Infer:
#   infer -- gradle <gradle_task>
#   infer -- xcodebuild -target <target_name> -configuration <build_configuration> -sdk iphonesimulator
#   infer -- xcodebuild -workspace <workspace_name> -scheme <scheme_name> -configuration <build_configuration> -sdk iphonesimulator
#
set -o pipefail
<infer_analyze_command> | ruby junit_output_of_infer.rb $PWD/infer_junit_results.xml
```
* **Post-build Actions** -> **Publish JUnit test result report** -> **Test report XMLs** -> infer_junit_results.xml

## Troubleshooting
* **Q**: `<some_internal_ruby_file>.rb:<line_number>: warning: Insecure world writable dir </some/path> in PATH, mode 040777`
* **A**: `chmod go-w </some/path>`
