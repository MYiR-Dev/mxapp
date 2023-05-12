#include "translator.h"
#include <QTranslator>
#include <QApplication>
#include <QDebug>
#include <QQmlEngine>

#include <QQmlApplicationEngine>
Translator *Translator::getInstance()
{
    static Translator transInstance;
    return &transInstance;
}

Translator::Translator(QObject *parent) : QObject(parent)
{
    m_translator = new QTranslator;
    m_current_language = "Chinese";
}

Translator::~Translator()
{
    delete m_translator;
}
void Translator::set_QQmlEngine(QQmlApplicationEngine *engine){
    m_engine = engine;
}
QString Translator::get_current_language()
{
    return m_current_language;
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
            m_current_language = "English" ;
            emit languageChanged("English");
            //m_engine->retranslate();
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
            m_current_language = "Chinese" ;
            emit languageChanged("Chinese");
            //m_engine->retranslate();
        }
        else
        {
            qDebug()<<"load cn error";
        }
    }
}
