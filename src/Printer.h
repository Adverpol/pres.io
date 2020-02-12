#pragma once

#include <QObject>
#include <QColor>

#include <memory>

class QQuickTextDocument;
class QQuickImage;


struct PrintState : public QObject
{
Q_OBJECT

public:
    qreal x = 0.;
    qreal y = 0.;

    int   column = 0;
    int   nColumns = 0;
    qreal maxColHeight = 0;

    void  addHeight(qreal height);
};

class Printer : public QObject
{
    Q_OBJECT

public slots:
    void printText(PrintState* state, QString text);
    void printHtml(PrintState* state, QString text);
    void printMarkdown(PrintState* state, QString text);
    void printDocument(PrintState* state, QQuickTextDocument* doc);
    void printImage(PrintState* state, QString url);
    void newLine(PrintState* state) const;

    void startColumns(PrintState* state, int nCols) const;
    void nextColumn(PrintState* state) const;
    void endColumns(PrintState* state) const;

public:
    Printer();
    ~Printer();

private:
    struct Pimpl;
    std::unique_ptr<Pimpl> m_p;
};
