#pragma once

#include <QAbstractListModel>

#include <memory>


struct TextItem
{
    QString text;
    /// todo!sv use variant
    /// -1: nothing
    ///  0: bullet
    /// 1+: number
    int     index = -1;
    int     indent = 0;
};

class TextModel : public QAbstractListModel
{
Q_OBJECT

Q_PROPERTY(QString text READ getEmptyString WRITE setText NOTIFY dummySignal)

signals:
    void dummySignal();

public:
    TextModel();

    QString getEmptyString() const { return ""; }
    void    setText(const QString& text);

    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    enum Roles
    {
        TextRole,
        IsBulletRole,
        IsNumberRole,
        NumberRole,
        IndentRole
    };

    std::vector<TextItem> m_items;
};
