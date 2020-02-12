#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>

#include "Printer.h"
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

    Util util(app);

    qmlRegisterType<Launcher>("presio", 1, 0,  "Launcher");
    qmlRegisterType<TextModel>("presio", 1, 0, "TextModel");
    qmlRegisterType<Printer>("presio", 1, 0,   "Printer");
    qmlRegisterType<PrintState>("presio", 1, 0,   "PrintState");

    engine.rootContext()->setContextProperty("cpp_util",    &util);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;


    return app.exec();
}
