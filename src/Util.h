#pragma once

#include <QObject>


class Util : public QObject
{
Q_OBJECT

public slots:
    static QString plainToRichText(QString text, QString fontFamily = "", int fontPointSize = 10);
    static QString richToPlainText(QString text);
    static QString syntaxHighlight(QString richText);
    static void    writeFile(QString fileName, QString content);
    static QString readFile(QString fileName);
};
