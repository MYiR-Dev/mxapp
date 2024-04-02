/***********************************************************************
 *  This file is part of MXAPP2

    Copyright (C) 2020-2024

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    Additional permission under GNU Lesser General Public License version 3.0
    See <https://www.gnu.org/licenses/lgpl-3.0.html> for more details.
***********************************************************************/

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
            m_engine->retranslate();
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
            m_engine->retranslate();
        }
        else
        {
            qDebug()<<"load cn error";
        }
    }
}
