//
//  SearchRepositoryViewController.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


let startLoadingOffset: CGFloat = 20.0
let reuseIdentifier = "Cell"

class SearchRepositoryViewController: ViewController,StoryboardInitializable {
    
    fileprivate var searchBar: UISearchBar!
    fileprivate var tableView: UITableView!
    
    var safeArea: UILayoutGuide!
    
    let activityIndicator = ActivityIndicator()
    
    var viewModel: SearchRepositoryViewModel!
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>(
        configureCell: { (_, tv, ip, repository: Repository) in
            var cell = tv.dequeueReusableCell(withIdentifier: reuseIdentifier)!
            cell = UITableViewCell(style: .subtitle,
                                   reuseIdentifier: reuseIdentifier)
            cell.textLabel?.text = repository.name
            cell.detailTextLabel?.text = repository.url.absoluteString
            return cell
    },
        titleForHeaderInSection: { dataSource, sectionIndex in
            let section = dataSource[sectionIndex]
            return section.items.count > 0 ? "Repositories (\(section.items.count))" : "No repositories found"
    }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        let loadNextPageTrigger: (Driver<SearchState>) -> Signal<()> =  { state in
            self.tableView.rx.contentOffset.asDriver()
                .withLatestFrom(state)
                .flatMap { state in
                    return self.tableView.isNearBottomEdge(edgeOffset: startLoadingOffset) && !state.shouldLoadNextPage
                        ? Signal.just(())
                        : Signal.empty()
            }
        }
        
        let state = viewModel.createState(
            searchText: searchBar.rx.text.orEmpty
                        .changed
                            .asSignal()
                                .throttle(.milliseconds(300))
                                    .skip(2),
                                        loadNextPageTrigger: loadNextPageTrigger,
                                        performSearch: { queryString , nextPage in
                                            self.viewModel.searchRepository(by:queryString, nextPage: nextPage)
                                                .trackActivity(self.activityIndicator)
                                    }).debug()
        
        state
            .map { $0.isOffline }
            .debug()
            .drive(self.rx.isOffline)
            .disposed(by: disposeBag)
        
        state
            .map { $0.repositories }
            .debug("***********Repository maps", trimOutput: false)
            .distinctUntilChanged()
            .map { [SectionModel(model: "Repositories", items: $0.value)] }
            .debug("***distic repos***", trimOutput: false)
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Repository.self)
            .subscribe(onNext: { repository in
                UIApplication.shared.open(repository.url, options: [:], completionHandler: nil)
            })
            .disposed(by:disposeBag)
        
        state
            .map { $0.isLimitExceeded }
            .debug()
            .distinctUntilChanged()
            .filter { $0 }
            .drive(onNext: { n in
                Banner.show(message: "Exceeded limit of 10 non authenticated requests per minute for GitHub API. Please wait a minute. :(\nhttps://developer.github.com/v3/#rate-limiting", view: self.view)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .subscribe { _ in
                if self.searchBar.isFirstResponder {
                    _ = self.searchBar.resignFirstResponder()
                }
        }
        .disposed(by: disposeBag)
        
        // so normal delegate customization can also be used
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        activityIndicator
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        tableView = UITableView()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
}


extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = startLoadingOffset) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}

// MARK: Table view delegate

extension SearchRepositoryViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

class ViewController: UIViewController {
    var disposeBag = DisposeBag()
}

