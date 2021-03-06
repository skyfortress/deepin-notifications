/**
 * Copyright (C) 2014 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

#ifndef BUBBLE_H
#define BUBBLE_H

#include <QFrame>
#include <dimagebutton.h>

DWIDGET_USE_NAMESPACE

class QLabel;
class AppIcon;
class QPropertyAnimation;
class QParallelAnimationGroup;
class NotificationEntity;
class ActionButton;
class Bubble : public QFrame
{
    Q_OBJECT
public:
    Bubble(NotificationEntity *entity=0);

    void setXBasePosition(int);
    void setupPosition();

    NotificationEntity *entity() const;
    void setEntity(NotificationEntity *entity);

signals:
    void expired(int);
    void dismissed(int);
    void replacedByOther(int);
    void actionInvoked(int, QString);
    void aboutToQuit();

public slots:
    QPoint getCursorPos();
    void setMask(int, int, int, int);
    void closeButtonClicked();

protected:
    void mousePressEvent(QMouseEvent *) Q_DECL_OVERRIDE;

private:
    NotificationEntity *m_entity;

    QFrame *m_bgContainer = nullptr;
    QFrame *m_background = nullptr;
    AppIcon *m_icon = nullptr;
    QLabel *m_title = nullptr;
    QLabel *m_body = nullptr;
    ActionButton *m_actionButton = nullptr;
    DImageButton *m_closeButton = nullptr;
    QPropertyAnimation *m_inAnimation = nullptr;
    QParallelAnimationGroup *m_outAnimation = nullptr;

    QTimer *m_outTimer = nullptr;
    QTimer *m_aboutToOutTimer = nullptr;

    void updateContent();
    void initUI();
    void initAnimations();
    void initTimers();
    bool containsMouse() const;
    void processActions();
};

#endif // BUBBLE_H
