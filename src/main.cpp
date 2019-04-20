#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "Util.h"
#include "Launcher.h"


int main(int argc, char* argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    Util util;

    qmlRegisterType<Launcher>("storio", 1, 0, "Launcher");

    engine.rootContext()->setContextProperty("cpp_util", &util);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;


    return app.exec();
}
