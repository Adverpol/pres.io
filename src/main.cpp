#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "Util.h"
#include "Launcher.h"
#include "TextModel.h"


int main(int argc, char* argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    app.setOrganizationName("cppdreams");
    app.setOrganizationDomain("org");

    QQmlApplicationEngine engine;

    Util util;

    qmlRegisterType<Launcher>("presio", 1, 0, "Launcher");
    qmlRegisterType<TextModel>("presio", 1, 0, "TextModel");

    engine.rootContext()->setContextProperty("cpp_util", &util);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;


    return app.exec();
}
