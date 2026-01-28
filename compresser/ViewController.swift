//
//  ViewController.swift
//  compresser
//
//  Created by Misha Causur on 26.01.2026.
//

import UIKit

class ViewController: UIViewController {

    private let zlib = ZlibHelper()

    private lazy var ui = createUI()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Compress Lab"

        setupUI()
        layout()

        ui.inputTextView.text = "hello hello hello hello hello"
        updateSizes(original: nil, compressed: nil)
    }

    @objc private func didTapCompress() {
        ui.errorLabel.text = nil

        let original = Data(ui.inputTextView.text.utf8)
        do {
            let compressed = try zlib.compress(original)
            ui.base64TextView.text = compressed.base64EncodedString()
            updateSizes(original: original.count, compressed: compressed.count)
        } catch {
            show(error: error)
        }
    }

    @objc private func didTapDecompress() {
        ui.errorLabel.text = nil

        guard let b64 = ui.base64TextView.text, !b64.isEmpty else {
            ui.errorLabel.text = "Base64 is empty"
            return
        }
        guard let compressed = Data(base64Encoded: b64) else {
            ui.errorLabel.text = "Invalid Base64"
            return
        }

        do {
            let restored = try zlib.decompress(
                compressed,
                maxOutputBytes: 5 * 1024 * 1024
            )
            ui.restoredTextView.text =
                String(data: restored, encoding: .utf8) ?? "<not UTF-8>"
        } catch {
            show(error: error)
        }
    }

    private func updateSizes(original: Int?, compressed: Int?) {
        if let o = original {
            ui.originalLabel.text = "Original: \(o) B"
        } else {
            ui.originalLabel.text = "Original: —"
        }

        if let c = compressed {
            ui.compressedLabel.text = "Compressed: \(c) B"
        } else {
            ui.compressedLabel.text = "Compressed: —"
        }

        if let o = original, let c = compressed, o > 0 {
            let ratio = Double(c) / Double(o)
            ui.ratioLabel.text = String(format: "Ratio: %.2f", ratio)
        } else {
            ui.ratioLabel.text = "Ratio: —"
        }
    }

    private func show(error: Error) {
        ui.errorLabel.text = String(describing: error)
    }
}

extension ViewController {

    struct UI {
        let inputTextView: UITextView
        let base64TextView: UITextView
        let restoredTextView: UITextView
        let originalLabel: UILabel
        let compressedLabel: UILabel
        let ratioLabel: UILabel
        let errorLabel: UILabel
        let compressButton: UIButton
        let decompressButton: UIButton
    }

    func createUI() -> UI {
        let inputTextView = UITextView()
        let base64TextView = UITextView()
        let restoredTextView = UITextView()
        let originalLabel = UILabel()
        let compressedLabel = UILabel()
        let ratioLabel = UILabel()
        let errorLabel = UILabel()
        let compressButton = UIButton(type: .system)
        let decompressButton = UIButton(type: .system)

        styleTextView(inputTextView)
        styleTextView(base64TextView)
        styleTextView(restoredTextView)

        originalLabel.text = "Original Text:"
        compressedLabel.text = "Compressed Base64:"
        ratioLabel.text = "Compression Ratio:"
        errorLabel.text = ""

        return UI(
            inputTextView: inputTextView,
            base64TextView: base64TextView,
            restoredTextView: restoredTextView,
            originalLabel: originalLabel,
            compressedLabel: compressedLabel,
            ratioLabel: ratioLabel,
            errorLabel: errorLabel,
            compressButton: compressButton,
            decompressButton: decompressButton,
        )
    }
    
    func setupUI() {

        styleTextView(ui.inputTextView)
        styleTextView(ui.base64TextView)
        styleTextView(ui.restoredTextView)

        ui.inputTextView.accessibilityLabel = "Input"
        ui.base64TextView.accessibilityLabel = "Compressed Base64"
        ui.restoredTextView.accessibilityLabel = "Restored"

        ui.originalLabel.font = .systemFont(ofSize: 13)
        ui.compressedLabel.font = .systemFont(ofSize: 13)
        ui.ratioLabel.font = .systemFont(ofSize: 13)

        ui.errorLabel.font = .systemFont(ofSize: 13)
        ui.errorLabel.textColor = .systemRed
        ui.errorLabel.numberOfLines = 0

        ui.compressButton.setTitle("Compress → Base64", for: .normal)
        ui.compressButton.addTarget(
            self,
            action: #selector(didTapCompress),
            for: .touchUpInside
        )

        ui.decompressButton.setTitle("Decompress Base64 → Text", for: .normal)
        ui.decompressButton.addTarget(
            self,
            action: #selector(didTapDecompress),
            for: .touchUpInside
        )

        [
            ui.inputTextView, ui.compressButton, ui.decompressButton,
            ui.originalLabel, ui.compressedLabel, ui.ratioLabel,
            ui.base64TextView, ui.restoredTextView, ui.errorLabel,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }


    func layout() {
        let g = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            ui.inputTextView.topAnchor.constraint(
                equalTo: g.topAnchor,
                constant: 12
            ),
            ui.inputTextView.leadingAnchor.constraint(
                equalTo: g.leadingAnchor,
                constant: 12
            ),
            ui.inputTextView.trailingAnchor.constraint(
                equalTo: g.trailingAnchor,
                constant: -12
            ),
            ui.inputTextView.heightAnchor.constraint(equalToConstant: 120),

            ui.compressButton.topAnchor.constraint(
                equalTo: ui.inputTextView.bottomAnchor,
                constant: 10
            ),
            ui.compressButton.leadingAnchor.constraint(
                equalTo: ui.inputTextView.leadingAnchor
            ),

            ui.decompressButton.centerYAnchor.constraint(
                equalTo: ui.compressButton.centerYAnchor
            ),
            ui.decompressButton.trailingAnchor.constraint(
                equalTo: ui.inputTextView.trailingAnchor
            ),

            ui.originalLabel.topAnchor.constraint(
                equalTo: ui.compressButton.bottomAnchor,
                constant: 10
            ),
            ui.originalLabel.leadingAnchor.constraint(
                equalTo: ui.inputTextView.leadingAnchor
            ),

            ui.compressedLabel.topAnchor.constraint(
                equalTo: ui.originalLabel.bottomAnchor,
                constant: 6
            ),
            ui.compressedLabel.leadingAnchor.constraint(
                equalTo: ui.inputTextView.leadingAnchor
            ),

            ui.ratioLabel.topAnchor.constraint(
                equalTo: ui.compressedLabel.bottomAnchor,
                constant: 6
            ),
            ui.ratioLabel.leadingAnchor.constraint(
                equalTo: ui.inputTextView.leadingAnchor
            ),

            ui.base64TextView.topAnchor.constraint(
                equalTo: ui.ratioLabel.bottomAnchor,
                constant: 10
            ),
            ui.base64TextView.leadingAnchor.constraint(
                equalTo: ui.inputTextView.leadingAnchor
            ),
            ui.base64TextView.trailingAnchor.constraint(
                equalTo: ui.inputTextView.trailingAnchor
            ),
            ui.base64TextView.heightAnchor.constraint(equalToConstant: 110),

            ui.restoredTextView.topAnchor.constraint(
                equalTo: ui.base64TextView.bottomAnchor,
                constant: 10
            ),
            ui.restoredTextView.leadingAnchor.constraint(
                equalTo: ui.inputTextView.leadingAnchor
            ),
            ui.restoredTextView.trailingAnchor.constraint(
                equalTo: ui.inputTextView.trailingAnchor
            ),
            ui.restoredTextView.heightAnchor.constraint(equalToConstant: 110),

            ui.errorLabel.topAnchor.constraint(
                equalTo: ui.restoredTextView.bottomAnchor,
                constant: 10
            ),
            ui.errorLabel.leadingAnchor.constraint(
                equalTo: ui.inputTextView.leadingAnchor
            ),
            ui.errorLabel.trailingAnchor.constraint(
                equalTo: ui.inputTextView.trailingAnchor
            ),
            ui.errorLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: g.bottomAnchor,
                constant: -12
            ),
        ])
    }

    fileprivate func styleTextView(_ tv: UITextView) {
        tv.font = .systemFont(ofSize: 15)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.separator.cgColor
        tv.layer.cornerRadius = 10
        tv.textContainerInset = UIEdgeInsets(
            top: 10,
            left: 8,
            bottom: 10,
            right: 8
        )
    }
}
