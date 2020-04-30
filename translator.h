#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <QObject>
class QTranslator;

class Translator : public QObject
{
    Q_OBJECT
public:
    static Translator* getInstance();

private:
    explicit Translator(QObject *parent = 0);
    ~Translator();

signals:
    void languageChanged();

public slots:
    void loadLanguage(QString lang);

private:
    QTranslator*  m_translator;
};

#endif // TRANSLATOR_H
