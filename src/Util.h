#pragma once

#include <QObject>
#include <QSettings>


class QCoreApplication;

class Util : public QObject
{
Q_OBJECT

Q_PROPERTY(QString lastUsedFile READ getLastUsedFile WRITE setLastUsedFile NOTIFY lastUsedFileChanged)

signals:
    void lastUsedFileChanged();

public slots:
    static QString plainToRichText(QString text, QString fontFamily = "", int fontPointSize = 10);
    static QString richToPlainText(QString text);
    static QString syntaxHighlight(QString richText);
    static void    writeFile(QString fileName, QString content);
    static QString readFile(QString fileName);
    static QString urlToLocalFile(QString url);

public:
    Util(const QCoreApplication& app);

    QString getLastUsedFile() const;
    void    setLastUsedFile(QString value);

private:
    QSettings m_settings;
};
