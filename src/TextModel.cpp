#include "TextModel.h"

#include <iostream>
#include <vector>

namespace
{

std::vector<TextItem> parseText(const QString& text)
{
    std::vector<TextItem> items;

    std::vector<int> runningNumbers = {0};
    int consequtiveNewlines = 0;

    for (const auto& line : text.split('\n'))
    {
        if (line.isEmpty()){
            ++consequtiveNewlines;
        } else {
            consequtiveNewlines = 0;
        }

        if (consequtiveNewlines == 2){
            runningNumbers.clear();
            // First newline was appended, which is good, don't append
            // the second.
            continue;
        }

        auto countStartingItems = [](const QString& line, QChar item)
        {
            int items = 0;
            while(line.length() > items && line[items] == item){
                ++items;
            }
            return items;
        };

        if (const int bullets = countStartingItems(line, '*'); bullets > 0)
        {
            items.emplace_back(TextItem{line.mid(bullets), 0, bullets-1});
        } else if (const int numbers = countStartingItems(line, '#'); numbers > 0)
        {
            const int indent = numbers - 1;
            if (runningNumbers.size() != static_cast<size_t>(numbers))
            {
                // If indent decreased we're removing numbers here, good: restart those
                // indent increased -> adding deeper levels
                runningNumbers.resize(static_cast<size_t>(numbers), 0);
                ++runningNumbers.back();
            }
            else {
                ++runningNumbers[static_cast<size_t>(indent)];
            }

            items.emplace_back(TextItem{line.mid(numbers), runningNumbers.back(), indent});
        } else if (items.empty())
        {
            items.emplace_back(TextItem{line, -1, 0});
        } else
        {
            items.back().text += '\n' + line;
        }
    }

    return items;
}

} // namespace

TextModel::TextModel()
    : m_items()
{
}

void TextModel::setText(const QString &text)
{
    beginResetModel();
    m_items = parseText(text);
    endResetModel();
}

int TextModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()){
        return 0;
    }

    return static_cast<int>(m_items.size());
}

QVariant TextModel::data(const QModelIndex &index, int role) const
{
    if (! index.isValid()
            || index.row() < 0
            || index.row() >= static_cast<int>(m_items.size()))
    {
        return {};
    }

    const TextItem& item = m_items[static_cast<size_t>(index.row())];

    switch(role){
    case TextRole: return item.text;
    case IsBulletRole: return item.index == 0;
    case IsNumberRole: return item.index > 0;
    case NumberRole: return item.index;
    case IndentRole: return item.indent;
    }

    return {};
}

QHash<int, QByteArray> TextModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[TextRole]     = "item_text";
    roles[IsBulletRole] = "is_bullet";
    roles[IsNumberRole] = "is_number";
    roles[IndentRole]   = "indent";
    roles[NumberRole]   = "number";

    return roles;
}
