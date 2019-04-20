#pragma once

#include <QObject>
#include <QProcess>

class Launcher : public QObject
{
    Q_OBJECT

public slots:
    QString launch(const QString &program);

public:
    Launcher(QObject *parent = nullptr);

private:
    QProcess m_process;
};
