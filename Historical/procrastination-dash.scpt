FasdUAS 1.101.10   ��   ��    l      ����  i         I     �� ��
�� .aevtoappnull  �   � ****  o      ���� 0 argv  ��    O     �  	  k    � 
 
     r        m       �   : P r o c r a s t i n a t i o n   D a s h   N o t i f i e r  l      ����  o      ���� 0 appname appName��  ��        r        m    	   �    B a c k   t o   w o r k !  l      ����  o      ���� 00 backtoworknotification backToWorkNotification��  ��        r        m       �    T a k e   a   b r e a k !  l      ����  o      ���� &0 breaknotification breakNotification��  ��       !   r     " # " m     $ $ � % % 
 E r r o r # l      &���� & o      ���� &0 errornotification errorNotification��  ��   !  ' ( ' l   ��������  ��  ��   (  ) * ) l   �� + ,��   + 1 + Make a list of all the notification types     , � - - V   M a k e   a   l i s t   o f   a l l   t h e   n o t i f i c a t i o n   t y p e s   *  . / . l   �� 0 1��   0 ' ! that this script will ever send:    1 � 2 2 B   t h a t   t h i s   s c r i p t   w i l l   e v e r   s e n d : /  3 4 3 r     5 6 5 J     7 7  8 9 8 o    ���� 00 backtoworknotification backToWorkNotification 9  : ; : o    ���� &0 breaknotification breakNotification ;  <�� < o    ���� &0 errornotification errorNotification��   6 l      =���� = o      ���� ,0 allnotificationslist allNotificationsList��  ��   4  > ? > l   ��������  ��  ��   ?  @ A @ l   �� B C��   B ( " Make a list of the notifications     C � D D D   M a k e   a   l i s t   o f   t h e   n o t i f i c a t i o n s   A  E F E l   �� G H��   G - ' that will be enabled by default.          H � I I N   t h a t   w i l l   b e   e n a b l e d   b y   d e f a u l t .             F  J K J l   �� L M��   L 9 3 Those not enabled by default can be enabled later     M � N N f   T h o s e   n o t   e n a b l e d   b y   d e f a u l t   c a n   b e   e n a b l e d   l a t e r   K  O P O l   �� Q R��   Q 7 1 in the 'Applications' tab of the growl prefpane.    R � S S b   i n   t h e   ' A p p l i c a t i o n s '   t a b   o f   t h e   g r o w l   p r e f p a n e . P  T U T r     V W V o    ���� ,0 allnotificationslist allNotificationsList W l      X���� X o      ���� 40 enablednotificationslist enabledNotificationsList��  ��   U  Y Z Y l     ��������  ��  ��   Z  [ \ [ l     �� ] ^��   ] &   Register our script with growl.    ^ � _ _ @   R e g i s t e r   o u r   s c r i p t   w i t h   g r o w l . \  ` a ` l     �� b c��   b 7 1 You can optionally (as here) set a default icon     c � d d b   Y o u   c a n   o p t i o n a l l y   ( a s   h e r e )   s e t   a   d e f a u l t   i c o n   a  e f e l     �� g h��   g ' ! for this script's notifications.    h � i i B   f o r   t h i s   s c r i p t ' s   n o t i f i c a t i o n s . f  j k j I    +���� l
�� .registernull��� ��� null��   l �� m n
�� 
appl m l 	 " # o���� o o   " #���� 0 appname appName��  ��   n �� p q
�� 
anot p l 
 $ % r���� r o   $ %���� ,0 allnotificationslist allNotificationsList��  ��   q �� s��
�� 
dnot s o   & '���� 40 enablednotificationslist enabledNotificationsList��   k  t u t l  , ,��������  ��  ��   u  v�� v Z   , � w x y z w =  , 6 { | { n   , 2 } ~ } 4   - 2�� 
�� 
cobj  m   0 1����  ~ o   , -���� 0 argv   | m   2 5 � � � � �  w o r k x I  9 R���� �
�� .notifygrnull��� ��� null��   � �� � �
�� 
name � l 	 = > ����� � o   = >���� 00 backtoworknotification backToWorkNotification��  ��   � �� � �
�� 
titl � l 	 A D ����� � m   A D � � � � �  T i m e  s   u p !��  ��   � �� � �
�� 
desc � l 	 G J ����� � m   G J � � � � �  B a c k   t o   w o r k !��  ��   � �� ���
�� 
appl � o   K L���� 0 appname appName��   y  � � � =  U _ � � � n   U [ � � � 4   V [�� �
�� 
cobj � m   Y Z����  � o   U V���� 0 argv   � m   [ ^ � � � � � 
 b r e a k �  ��� � I  b {���� �
�� .notifygrnull��� ��� null��   � �� � �
�� 
name � l 	 f g ����� � o   f g���� &0 breaknotification breakNotification��  ��   � �� � �
�� 
titl � l 	 j m ����� � m   j m � � � � �  R e l a x !��  ��   � �� � �
�� 
desc � l 	 p s ����� � m   p s � � � � �  T a k e   a   b r e a k !��  ��   � �� ���
�� 
appl � o   t u���� 0 appname appName��  ��   z I  ~ ����� �
�� .notifygrnull��� ��� null��   � �� � �
�� 
name � l 	 � � ����� � o   � ����� &0 errornotification errorNotification��  ��   � �� � �
�� 
titl � l 	 � � ����� � m   � � � � � � �  E r r o r !��  ��   � �� � �
�� 
desc � l 	 � � ����� � m   � � � � � � � P a r g v [ 0 ]   m u s t   b e   o n e   o f   ' w o r k '   o r   ' b r e a k '��  ��   � �� ���
�� 
appl � o   � ����� 0 appname appName��  ��   	 m      � �2                                                                                  GRRR   alis    �  Macintosh HD               �tH+   |n�GrowlHelperApp.app                                              |o+�n�u        ����  	                	Resources     �ւ      �o�     |n� |n� |n� ��      YMacintosh HD:Library:PreferencePanes:Growl.prefPane:Contents:Resources:GrowlHelperApp.app   &  G r o w l H e l p e r A p p . a p p    M a c i n t o s h   H D  LLibrary/PreferencePanes/Growl.prefPane/Contents/Resources/GrowlHelperApp.app  / ��  ��  ��       
�� � �    $ � �����   � ����������������
�� .aevtoappnull  �   � ****�� 0 appname appName�� 00 backtoworknotification backToWorkNotification�� &0 breaknotification breakNotification�� &0 errornotification errorNotification�� ,0 allnotificationslist allNotificationsList�� 40 enablednotificationslist enabledNotificationsList��   � �� ��� � ��~
�� .aevtoappnull  �   � ****�� 0 argv  �   � �}�} 0 argv   �  � �| �{ �z $�y�x�w�v�u�t�s�r�q ��p�o ��n ��m�l � � � � ��| 0 appname appName�{ 00 backtoworknotification backToWorkNotification�z &0 breaknotification breakNotification�y &0 errornotification errorNotification�x ,0 allnotificationslist allNotificationsList�w 40 enablednotificationslist enabledNotificationsList
�v 
appl
�u 
anot
�t 
dnot�s 
�r .registernull��� ��� null
�q 
cobj
�p 
name
�o 
titl
�n 
desc�m 
�l .notifygrnull��� ��� null�~ �� ��E�O�E�O�E�O�E�O���mvE�O�E�O*������� O�a k/a   *a �a a a a ��a  Y D�a k/a   *a �a a a a ��a  Y *a �a a a a ��a  U � �k ��k  �     $��   ascr  ��ޭ