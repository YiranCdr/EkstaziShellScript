import xml.etree.ElementTree as ET
import codecs
import sys

ekstaziPluginStr = "<plugin>" \
                   "<groupId>org.ekstazi</groupId>" \
                   "<artifactId>ekstazi-maven-plugin</artifactId>" \
                   "<version>5.3.0</version>" \
                   "<executions>" \
                   "<execution>" \
                   "<id>ekstazi</id>" \
                   "<goals>" \
                   "<goal>select</goal>" \
                   "</goals>" \
                   "</execution>" \
                   "</executions>" \
                   "</plugin>"
ekstaziPluginsStr = "<plugins><plugin>" \
                    "<groupId>org.ekstazi</groupId>" \
                    "<artifactId>ekstazi-maven-plugin</artifactId>" \
                    "<version>5.3.0</version>" \
                    "<executions>" \
                    "<execution>" \
                    "<id>ekstazi</id>" \
                    "<goals>" \
                    "<goal>select</goal>" \
                    "</goals>" \
                    "</execution>" \
                    "</executions>" \
                    "</plugin></plugins>"
ekstaziBuildStr = "<build><plugins><plugin>" \
                  "<groupId>org.ekstazi</groupId>" \
                  "<artifactId>ekstazi-maven-plugin</artifactId>" \
                  "<version>5.3.0</version>" \
                  "<executions>" \
                  "<execution>" \
                  "<id>ekstazi</id>" \
                  "<goals>" \
                  "<goal>select</goal>" \
                  "</goals>" \
                  "</execution>" \
                  "</executions>" \
                  "</plugin></plugins></build>"

if __name__ == "__main__":
    assert len(sys.argv) == 2
    destName = sys.argv[1]
    tree = ET.parse(destName)
    tag = tree.getroot().tag[:-7]
    ET.register_namespace("", tag[1:-1])
    ekstaziPluginTree = ET.fromstring(ekstaziPluginStr)
    tree.find(tag + "build/" + tag + "plugins").append(ekstaziPluginTree)
    with codecs.open(destName, "w", encoding="utf8") as f:
        f.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    tree.write(open(destName, 'ab'))
