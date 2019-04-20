#include "Launcher.h"



QString Launcher::launch(const QString &program)
{
    m_process.start(program);
    m_process.waitForFinished(-1);

    QString output = QString::fromLocal8Bit(m_process.readAllStandardError())
            + QString::fromLocal8Bit(m_process.readAllStandardOutput());

    return output;
}

Launcher::Launcher(QObject *parent)
    : QObject(parent)
{
}
