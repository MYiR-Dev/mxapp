#include "translator.h"
#include <QTranslator>
#include <QApplication>
#include <QDebug>

Translator *Translator::getInstance()
{
    static Translator transInstance;
    return &transInstance;
}

Translator::Translator(QObject *parent) : QObject(parent)
{
    m_translator = new QTranslator;
}

Translator::~Translator()
{
    delete m_translator;
}

void Translator::loadLanguage(QString lang)
{
    qDebug()<<"load"<<lang;
    if(NULL == m_translator)
    {
        return;
    }

    if(lang.contains("English"))
    {
        if(m_translator->load(":/languages/language_en.qm"))
        {
            QApplication::installTranslator(m_translator);
            emit languageChanged();
        }
        else
        {
            qDebug()<<"load en error";
        }
    }
    else
    {
        if(m_translator->load(":/languages/language_zh.qm"))
        {
            QApplication::installTranslator(m_translator);
            emit languageChanged();
        }
        else
        {
            qDebug()<<"load cn error";
        }
    }
}
