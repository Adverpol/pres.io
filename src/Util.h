#pragma once

#include <QObject>
#include <QSettings>
#include <QDateTime>


class QCoreApplication;

class Util : public QObject
{
Q_OBJECT

Q_PROPERTY(QString lastUsedFile READ getLastUsedFile WRITE setLastUsedFile NOTIFY lastUsedFileChanged)
Q_PROPERTY(int     isActive     READ isActive WRITE setActive NOTIFY isActiveChanged)


signals:
    void lastUsedFileChanged();
    void isActiveChanged();

public slots:
    static QString plainToRichText(QString text, QColor textColour,
                                   QString fontFamily = "", int fontPointSize = 10);
    static QString richToPlainText(QString text);
    static QString highlightRichText(QString richText);
    static QString highlightPlainText(QString plainText, QColor textColour,
                                      QString fontFamily = "", int fontPointSize = 10);
    static void    writeFile(QString fileName, QString content);
    static QString readFile(QString fileName);
    static QString urlToLocalFile(QString url);
    static QDateTime lastModified(QString url);

    bool isActive() const;
    void setActive(bool active);

public:
    Util(const QCoreApplication& app);

    QString getLastUsedFile() const;
    void    setLastUsedFile(QString value);

private:
    QSettings m_settings;
    bool m_isActive = false;
};
