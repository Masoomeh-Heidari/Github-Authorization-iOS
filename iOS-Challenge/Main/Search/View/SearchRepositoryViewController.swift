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

class SearchRepositoryViewController: TableViewController,StoryboardInitializable {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let activityIndicator = ActivityIndicator()
    
    var viewModel: SearchRepositoryViewModel!
    
    static let startLoadingOffset: CGFloat = 20.0

     let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>(
         configureCell: { (_, tv, ip, repository: Repository) in
             let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
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
        
        let loadNextPageTrigger: (Driver<SearchState>) -> Signal<()> =  { state in
            self.tableView.rx.contentOffset.asDriver()
                .withLatestFrom(state)
                .flatMap { state in
                    return self.tableView.isNearBottomEdge(edgeOffset: 20.0) && !state.shouldLoadNextPage
                        ? Signal.just(())
                        : Signal.empty()
                }
        }



        let state = viewModel.createState(
            searchText: searchBar.rx.text.orEmpty.changed.asSignal().throttle(.milliseconds(300)),
            loadNextPageTrigger: loadNextPageTrigger,
            performSearch: { queryString in
                self.viewModel.searchRepository(by:queryString)
                    .trackActivity(self.activityIndicator)
            })

        state
            .map { $0.isOffline }
            .drive(navigationController!.rx.isOffline)
            .disposed(by: disposeBag)

        state
            .map { $0.repositories }
            .distinctUntilChanged()
            .map { [SectionModel(model: "Repositories", items: $0.value)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Repository.self)
            .subscribe(onNext: { repository in
//                UIApplication.shared.openURL(repository.url)
            })
            .disposed(by:disposeBag)

        state
            .map { $0.isLimitExceeded }
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
}


extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}


class TableViewController: UITableViewController {
    var disposeBag = DisposeBag()
}

