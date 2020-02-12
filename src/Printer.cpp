#include "Printer.h"

#include <QtPrintSupport/QPrinter>
#include <QPainter>
#include <QQuickTextDocument>
#include <QAbstractTextDocumentLayout>
#include <QQuickImageProvider>

#include <iostream>


namespace
{

void newPageIfRequired(qreal height, PrintState* state, QPrinter& pdf)
{
    // This means that we only take the height of the first item into account
    // when determining columns newpage. To do differently we need methods to ask
    // an item for its height, or temp render to a dummy file to get the height
    // or something. Rendering to an intermediate format (e.g. html) is probably
    // a good solution, all content is then easily available to determine formatting.
    if (state->nColumns > 0 && state->x > 0){
        return;
    }

    if (state->y + height >= pdf.height()){
        pdf.newPage();
        state->y = 0;
    }
}

}

struct Printer::Pimpl
{
    QPrinter pdf;
    QPainter painter;
};

void Printer::printText(PrintState* state, QString text)
{
    const auto paintRect = m_p->pdf.pageLayout().paintRect(QPageLayout::Point);
    // todo!sv this width and height are probably not correct
    const auto boundingRect = QRectF(0, 0,
                                     paintRect.width(), paintRect.height());
    auto textRect = m_p->painter.boundingRect(boundingRect, 0, text);

//    std::wcout << textRect.height()
//               << " " << state->y
//               << " " << m_p->pdf.pageLayout().paintRect(QPageLayout::Point).height()
//               << " " << m_p->pdf.pageLayout().fullRect(QPageLayout::Point).height()
//               << std::endl;

    newPageIfRequired(textRect.height(), state, m_p->pdf);

    m_p->painter.resetTransform();
    m_p->painter.translate(state->x, state->y);
    m_p->painter.drawText(boundingRect, 0, text);
    state->addHeight(textRect.height());
}

void Printer::printHtml(PrintState* state, QString text)
{
    QTextDocument doc;
    doc.setHtml(text);

    const auto height = doc.size().height();
    newPageIfRequired(height, state, m_p->pdf);

//    // m_p->pdf.resolution() is 96 i.e. 96 dpi
//    std::wcout << "reso: " << m_p->pdf.resolution()
//               << " " << m_p->pdf.logicalDpiY()
//               << " " << m_p->pdf.physicalDpiY()
//               << " " << m_p->pdf.height()
////               << " " << m_p->pdf.PdmHeight
//               << std::endl;

    m_p->painter.resetTransform();
    m_p->painter.translate(state->x, state->y);
    doc.drawContents(&m_p->painter);

    state->addHeight(height);
}

void Printer::printMarkdown(PrintState *state, QString text)
{
    QTextDocument htmlDoc;

    {
        QTextDocument doc;
        doc.setMarkdown(text);

        // I don't know of a better way to set the font colour
        // in the markdown...
        htmlDoc.setDefaultStyleSheet(QString("body { color : %1 }").arg(QColor("black").name()));
        htmlDoc.setHtml(doc.toHtml());
    }

    const auto height = htmlDoc.size().height();
    newPageIfRequired(height, state, m_p->pdf);

    m_p->painter.resetTransform();

    // Required for the bullets
    m_p->painter.setBrush(QColor("black"));
    m_p->painter.translate(state->x, state->y);
    htmlDoc.drawContents(&m_p->painter);

    state->addHeight(height);
}

void Printer::printDocument(PrintState* state, QQuickTextDocument *doc)
{
    if (! doc)
        return;

    doc->textDocument()->drawContents(&m_p->painter);
    m_p->pdf.newPage();
}

void Printer::printImage(PrintState *state, QString url)
{
    // todo!sv we're actually re-loading the image here, QQuickImage is not readily
    // accessible from C++
    QImage image(QUrl(url).toLocalFile());

    // todo works well enough for now, should figure out the actual scale that's
    // being applied in the presentation
    const qreal xscale = 0.5;
    const qreal yscale = 0.5;

    newPageIfRequired(yscale * image.height(), state, m_p->pdf);

    m_p->painter.resetTransform();
    // center the image
    m_p->painter.translate(state->x + 0.5*(m_p->pdf.width() - xscale*image.width()), state->y);

    m_p->painter.scale(xscale, yscale);
    m_p->painter.drawImage(QPointF(0, 0), image);

    state->addHeight(yscale * image.height());
}

void Printer::newLine(PrintState* state) const
{
    state->addHeight(30);
}

void Printer::nextColumn(PrintState *state) const
{
    if (state->nColumns > 0){
        ++state->column;
        state->x = state->column * m_p->pdf.width() / state->nColumns;
    }
}

void Printer::startColumns(PrintState *state, int nCols) const
{
    state->nColumns = nCols;
    state->column   = 0;
}

void Printer::endColumns(PrintState *state) const
{
    state->x = 0;
    state->y += state->maxColHeight;

    state->nColumns = 0;
    state->maxColHeight = 0;
}

Printer::Printer()
    : m_p(std::make_unique<Pimpl>())
{
    m_p->pdf.setOutputFileName("/home/sanderv/test.pdf");

    m_p->pdf.setOutputFormat(QPrinter::PdfFormat);
    m_p->pdf.setOrientation(QPrinter::Portrait);
    m_p->pdf.setPaperSize(QPrinter::A4);
    m_p->pdf.setColorMode(QPrinter::Color);
    m_p->pdf.setPageMargins(10.0,10.0,10.0,10.0,QPrinter::Millimeter);
    m_p->pdf.setFullPage(false);

    m_p->painter.begin(&m_p->pdf);
}

Printer::~Printer()
{
    m_p->painter.end();
}

void PrintState::addHeight(qreal height)
{
    if (nColumns > 0) {
        maxColHeight = std::max(maxColHeight, height);
    } else {
        y += height;
    }
}
