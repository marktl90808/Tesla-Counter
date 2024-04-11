////
////  AboutView.swift
////  Tesla Counter
////
////  Created by Mark Leonard on 3/30/24.
////
//import SwiftUI
//import UIKit
//
//struct AboutView: View {
//
//class ViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let longText = """
//        TESLA Counter by Mark Leonard \n\nI created this app because I like Tesla Electric Vehicles. It seems like I see more and more of them where ever I go. Every time I was out with some family members and we would see one, we'd say \"Tesla!\"\nThen when we would arrive at our destination or our home we would ask \"How many Teslas did we see?\"\n\nSometimes we would say \"a lot\" and other times we would say how many  we thought we saw. Then someone would say \"Really? Are you sure?\"\nSo I said I'd build an App that would track how many we saw. I thought it should have some images on it and each time the main image was tapped it would increase the count. It would show a running tally for the day. \nSo when you see a Tesla, tap the main image on the app, the count will go up by 1. You will also hear me say \"Tesla!\"\nIf you click the TESLA word at the top of the display, you will be able to set or modify the number, then click \"Submit\"\nCounting will resume from that number. The number (AKA \"Count\" will also be saved so that if you close the app, the next time you open it should be able to resume where you left off. The count does reset each day and previous days counts will be displayed when you click on the \"Current/Daily Counts:\" button. If you don't want to hear me call out each time the image is tapped, you can turn off the sound until you want to turn the sound back on. \nI found the images on the website \"https://www.pexels.com/photo/white-car-with-blacktop-on-the-road-9482552/\"
//        """
//
//        let label = UILabel()
//        label.numberOfLines = 0 // Allow multiline
//        label.text = longText
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .black
//
//        view.addSubview(label)
//
//        // Set Auto Layout constraints (adjust as needed)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
//        ])
//    }
//}
//
//
//    var body: some View {
//        VStack {
//            Text(label.text).padding()
//            NavigationView {
//                NavigationLink(destination: ContentView()) {
//                    Text("Go to Content screen")
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    AboutView()
//}
