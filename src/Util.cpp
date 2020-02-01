#include "Util.h"

#include <QUrl>
#include <QtGui>

#include <iostream>


QString Util::plainToRichText(QString text, QString fontFamily, int fontPointSize)
{
    // Use this to get the whole html shebaing, doctype and everything included
    QTextDocument doc;

    if (! fontFamily.isEmpty()){
        QFont font;
        font.setFamily(fontFamily);
        font.setPointSize(fontPointSize);
        doc.setDefaultFont(font);
    }

    doc.setPlainText(text);
    return doc.toHtml();
}

QString Util::richToPlainText(QString text)
{
    QTextDocument doc;
    doc.setHtml(text);
    return doc.toPlainText();
}

QString Util::highlightPlainText(QString plainText, QString fontFamily, int fontPointSize)
{
    return highlightRichText(plainToRichText(plainText, fontFamily, fontPointSize));
}

// todo!sv reimplement using QSyntaxHighlighter
QString Util::highlightRichText(QString richText)
{
    auto keywords = {"int", "float", "double", "long", "string", "char", "auto", "const",
                     "std",
                     "return", "if", "then", "else", "while", "break", "include", "#pragma once"};

    // Whole next code should be replaced by QSyntaxHighlighter or even better a library that does that
    // for us...
    QString parsed;
    for (auto line: richText.split('\n')){
        // Contains //, don't parse as comment
        if (line == R"(<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">)"){
            parsed += line;
        } else if (const auto commentIndex = line.indexOf("//"); commentIndex >= 0){
            line.insert(commentIndex, "<span style=\"color:#cd8b00\">");
            line += "</span>";
        } else {
            for (const auto& keyword : keywords){
                QRegularExpression regexp(QString("\\b") + keyword + "\\b");
                line.replace(regexp, QString("<span style=\"color:#808bed\">") + keyword + "</span>");
            }
        }

        parsed += line;
    }

    return parsed;
}

void Util::writeFile(QString fileName, QString content)
{
    QFile file(fileName);
    if (!file.open(QFile::WriteOnly | QFile::Truncate)){
        return;
    }

    QTextStream out(&file);
    out << content;
    file.close();
}

QString Util::readFile(QString fileName)
{
    QFile file(fileName);
    if (!file.open(QFile::ReadOnly | QFile::Text)){
        std::cerr << "Unable to open file '" << fileName.toStdString() << "' for reading" << std::endl;
        return "";
    }

    QTextStream in(&file);
    return in.readAll();
}

QString Util::urlToLocalFile(QString url)
{
    return QUrl(url).toLocalFile();
}

bool Util::isActive() const
{
    return m_isActive;
}

void Util::setActive(bool active)
{
    if (active != m_isActive){
        m_isActive = active;
        isActiveChanged();
    }
}

Util::Util(const QCoreApplication &app)
    : m_settings(app.organizationName(), "pres.io")
{
}

QString Util::getLastUsedFile() const
{
    return m_settings.value("main/lastUsedFile").toString();
}

void Util::setLastUsedFile(QString value)
{
    m_settings.setValue("main/lastUsedFile", value);
}
