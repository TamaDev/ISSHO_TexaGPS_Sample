ISSHO_TexaGPS_Sample  
TexaGPS is mobile GPS server.  
This application multi cast GPS information to any iOS devices!  

See also TexaGPS sites and AppStore.  
http://issho.dht.jp/texaGPS/  
https://itunes.apple.com/jp/app/texagps/id581198980?mt=8  
  
This repository is TexaGPS sample code and library.  
ARMV7, ARMV7s, i386 support. Required iOS5.1 and iOS6 later.  
Please refer to Preset2x3.zip, preset3x3.zip for the sample of the user definition panel.
  
**** CAUTION! ****  
This sample project contained TexaGPS.framework by the hard-linked for restrictions of github.   
When you include a TexaGPS framework in your project, please following next procedures.   
1. Unzip TexaGPSLib/*/TexaGPS.x.x.zip other directory.  
2. Extract TexaGPS.framework copy to your project.(iOS universal framework)  
3. Add TexaGPS.framework to your project.  

TexaGPS.framework is dependent on these Frameworks.   
CFNetwork.framework  
CoreLocation.framework  
SystemConfiguration.framework  
Foundation.framework  
  
  
  
TexaGPSはモバイルGPSサーバーです  
このアプリケーションはGPS情報を複数のiOS機器へマルチキャストします。  
詳しくはTexaGPSのサイトとAppStoreを参照してください。  
http://issho.dht.jp/texaGPS/  
https://itunes.apple.com/jp/app/texagps/id581198980?mt=8  
	
このリポジトリはTexaGPSのサンプルコードとライブラリーです。  
ARMV7, ARMV7s, i386をサポートします。iOS5.1とiOS6以降が必要です。  
ユーザー定義パネルのサンプルはPreset2x3.zip、preset3x3.zipを参照してください。

**** 注意事項！ ****  
このプロジェクト内のTexaGPS.frameworkはgithubの制約のためにハードリンクで含まれています。  
TexaGPSのフレームワークをあなたのプロジェクトに追加する場合、以下の手順で進めてください。  
1. プロジェクトに含まれるTexaGPSLib/*/TexaGPS.x.x.zipをプロジェクト外のディレクトリで展開してください。  
2. 展開されたTexaGPS.frameworkをあなたのプロジェクトへコピーします。  
3. TexaGPS.frameworkをプロジェクトに追加してください。  

TexaGPS.frameworkは以下のFrameworkに依存しています。  
CFNetwork.framework  
CoreLocation.framework  
SystemConfiguration.framework  
Foundation.framework  
  
