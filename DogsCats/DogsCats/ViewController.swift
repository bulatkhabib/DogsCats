//
//  ViewController.swift
//  DogsCats
//
//  Created by Булат Хабибуллин on 28.12.2021.
//

import UIKit
import Combine
import Kingfisher
import SnapKit

class ViewController: UIViewController {
    
    // MARK: Private properties
    
    private var serviceSubscriber: AnyCancellable?
    private var segmentedControlSubscriber: AnyCancellable?
    private var catsSubscriber: AnyCancellable?
    private var dogsSubscriber: AnyCancellable?
    
    @Published private var dogs = Dog()
    @Published private var cats = Cat()
    
    @Published private var sumOfCats = 0
    @Published private var sumOfDogs = 0
    
    @Published private var segmentIndex: Int = 0
    
    private var textView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 10.0
        
        return textView
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1.0
        imageView.layer.cornerRadius = 10.0
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Cats", "Dogs"])
        segmentedControl.addTarget(self, action: #selector(switchSegmentedControl(_:)), for: .valueChanged)
        
        return segmentedControl
    }()
    
    private var scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Score: 0 cats and 0 dogs"
        
        return label
    }()
    
    private var moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("more", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.layer.cornerRadius = 20.0
        button.backgroundColor = UIColor(named: "moreButtonColor")
        button.addTarget(self, action: #selector(moreButtonTap), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: Setup
    
    func setup() {
        view.addSubview(segmentedControl)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(27)
        }
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(205)
            make.top.equalTo(segmentedControl.snp.bottom).offset(41)
            make.leading.equalToSuperview().offset(19)
            make.trailing.equalToSuperview().inset(18)
        }
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.height.equalTo(205)
            make.top.equalTo(segmentedControl.snp.bottom).offset(41)
            make.leading.equalToSuperview().offset(19)
            make.trailing.equalToSuperview().inset(18)
        }
        
        view.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(144)
            make.height.equalTo(40)
            make.top.equalTo(imageView.safeAreaLayoutGuide.snp.bottom).offset(13)
        }
        
        view.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(moreButton.snp.bottom).offset(19)
            make.leading.equalToSuperview().offset(22)
            make.bottom.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).inset(327)
            make.trailing.equalToSuperview().inset(22)
        }
    }
    
    func setupContentView() {
        segmentedControlSubscriber = $segmentIndex
            .receive(on: DispatchQueue.main)
            .sink (receiveCompletion: { _ in }, receiveValue: { index in
                if index == 0 {
                    self.textView.isHidden = false
                    self.imageView.isHidden = true
                } else {
                    self.textView.isHidden = true
                    self.imageView.isHidden = false
                }
            })
        
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cats and dogs"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetButtonTap))
        
        setup()
        setupContentView()
    }
    
    // MARK: Objective methods
    
    @objc func switchSegmentedControl(_ sender: UISegmentedControl) {
        segmentIndex = sender.selectedSegmentIndex
    }
    
    @objc func moreButtonTap() {
        if segmentedControl.selectedSegmentIndex == 0 {
            getCatsContent()
            textView.text = cats.fact
            sumOfCats += 1
        } else {
            getDogsContent()
            guard let imageUrl = dogs.message else { return }
            let url = URL(string: imageUrl)
            imageView.kf.setImage(with: url)
            sumOfDogs += 1
        }
        
        setupAnimalCount()
    }
    
    @objc func resetButtonTap() {
        sumOfCats = 0
        sumOfDogs = 0
        textView.text = nil
        imageView.image = nil
    }
    
    // MARK: Private methods
    
    private func getDogsContent() {
        serviceSubscriber = NetworkService().dogsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { dog in
                self.dogs = dog
            })
    }
    
    private func getCatsContent() {
        serviceSubscriber = NetworkService().catsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { cat in
                self.cats = cat
            })
    }
    
    private func setupAnimalCount() {
        
        dogsSubscriber = $sumOfDogs
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.scoreLabel.text = "Score: \(self.sumOfCats) cats and \(value) dogs"
            }
        
        catsSubscriber = $sumOfCats
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.scoreLabel.text = "Score: \(value) cats and \(self.sumOfDogs) dogs"
            }
    }
    
}

