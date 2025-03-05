//
//  MPITextSwfitExampleViewController.swift
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/4/8.
//  Copyright © 2019 美图网. All rights reserved.
//

import MPITextKit
import UIKit

@objc
class MPITextSwfitExampleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white

        MPIExampleHelper.addDebugOption(to: self)

        let helloWorldAttributedText = NSMutableAttributedString(string: "你好！Hello World. ")
        let link = MPIExampleLink()
        link.value = NSString(string: "https://meitu.com")
        link.linkType = .url
        let tapmeAttributedText = NSAttributedString(string: "Tap me!", attributes: [.MPILink: link, .foregroundColor: UIColor(red: 0.000, green: 0.449, blue: 1.000, alpha: 1.000)])
        helloWorldAttributedText.append(tapmeAttributedText)

        let attributedText = NSMutableAttributedString()
        attributedText.append(helloWorldAttributedText)
        attributedText.append(NSAttributedString(string: "\n"))
        attributedText.append(helloWorldAttributedText)
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 25), range: attributedText.mpi_rangeOfAll())
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: attributedText.mpi_rangeOfAll())

        let mpiLabel = MPILabel()
        mpiLabel.attributedText = attributedText
        mpiLabel.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        mpiLabel.numberOfLines = 0
        mpiLabel.delegate = self

        mpiLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mpiLabel)

        mpiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mpiLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

extension MPITextSwfitExampleViewController: MPILabelDelegate {
    func label(_: MPILabel, didInteractWith link: MPITextLink, forAttributedText attributedText: NSAttributedString, in characterRange: NSRange, interaction _: MPITextItemInteraction) {
        let exLink = link as! MPIExampleLink
        print("Tapped => text: \(attributedText.attributedSubstring(from: characterRange).string)" + "value: " + String(exLink.value as! NSString) + " linkType: \(exLink.linkType)")
    }
}
