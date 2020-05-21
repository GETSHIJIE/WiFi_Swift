//
//  IPconnection.swift
//  SBox
//
//  Created by 黃仕杰 on 2018/4/21.
//  Copyright © 2018年 SBox. All rights reserved.
//

import UIKit

class communication: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var btnDisconnect: UIButton!
    @IBOutlet var btnConnect: UIButton!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var editIP: UITextField!
    @IBOutlet var editPort: UITextField!
    @IBOutlet var editData: UITextField!
    @IBOutlet var showIP: UILabel!
    @IBOutlet var showStatus: UILabel!
    @IBOutlet var showDetail: UITextView!
    
    let wifi = WiFi_Communication();
    var timer: Timer?;
    
    var crtConnect: Bool = false;
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear");
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear");
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear");
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear");
    }
    
    
    @IBAction func btnConnectClick(_ sender: Any) {
        let ip = editIP.text! as CFString;
        let port = UInt32(editPort.text!);
        
        let fg = wifi.connective(addr: ip  , port: port!);
        if(fg){
            showStatus.text = "連線中...";
            
            wifi.sendData("ws#1##jie");
            
            self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true);
            
            wifi.receive { (msg) in
                self.showDetail.insertText("回傳值>>> " + msg + "\n");
                var msgSep: [String] = [] ;
                msgSep = msg.components(separatedBy: "#");
                
                if(detachPacket(msgSep)){
                    self.wifi.sys(true);
                    self.crtConnect = true;
                    self.showStatus.text = "已連線";
                }
            }
        }
    }
    
    @objc func runTimedCode() {
        print("crtConnect=\(crtConnect)");
        
        if(!crtConnect){
            Disconnection();
        }else{
            wifi.sendData(socketFormat(""));
            crtConnect = false;
        }
    }
    
    
    @IBAction func btnSendClick(_ sender: Any) {
        let text = socketFormat(editData.text!);
        wifi.sendData(text);
        //wifi.sendPNG();
    }
    
    
    @IBAction func btnDisconnectClick(_ sender: Any) {
        Disconnection()
    }
    
    func Disconnection() -> Void{
        wifi.sys(false);
        crtConnect = false;
        timer?.invalidate();
        showDetail.text = "";
        showStatus.text = "已斷線";
    }
    
    
    
    //--------------------------------------------------------------------
    // 觸控到螢幕,超出keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    //--------------------------------------------------------------------
    // 觸控到鍵盤return,在keyboard內
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editIP.resignFirstResponder();
        editPort.resignFirstResponder();
        editData.resignFirstResponder();
        
        return(true);
    }
    
}


func socketFormat(_ str: String) -> String{
    let first = "ws";
    let end = "jie";
    var StringFormat: String = "";
    StringFormat = first+"#"+"1#"+str+"#"+end+"\n";
    
    return StringFormat;
}

func detachPacket(_ SepStr: [String]) -> Bool {
    
    //---確認封包陣列長度---
    if(SepStr.count != 4){
        print("封包長度錯誤");
        return false;
    }else{
        print("封包長度正確");
    }
    
    //---封包前後碼確認---
    if(SepStr[0] != "ws" && SepStr[SepStr.count-1] != "jie"){
        print("封包格式錯誤");
        return false;
    }else{
        print("封包格式正確");
    }
    
    //---判斷是否一直在線---
    if(SepStr[1] != "1"){
        print("連線狀態XX");
        return false;
    }else{
        print("連線狀態OK\n----------");
    }
    
    return true;
}
