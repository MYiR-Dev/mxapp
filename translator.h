#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <QObject>
#include <QQmlApplicationEngine>
class QTranslator;

class Translator : public QObject
{
    Q_OBJECT
public:
    QQmlApplicationEngine *m_engine;
    static Translator* getInstance();
    void set_QQmlEngine(QQmlApplicationEngine *engine);

    QString m_current_language;
private:
    explicit Translator(QObject *parent = 0);
    ~Translator();

signals:
    void languageChanged(QString lang);

public slots:
    void loadLanguage(QString lang);
    QString get_current_language();

private:
    QTranslator*  m_translator;
};

#endif // TRANSLATOR_H
