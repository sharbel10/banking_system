import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../banking/domain/entities/account_entity.dart';
import '../../../banking/domain/entities/transaction_entity.dart';
import '../../../banking/patterns/facade/banking_facade.dart';

class NewTransactionState {
  final bool loading;

  final List<AccountEntity> accounts;
  final String? selectedFromId;
  final String? selectedToId;

  final TransactionType type;
  final double fromBalance;

  final TransactionEntity? tx;
  final String? error;

  const NewTransactionState({
    required this.loading,
    required this.accounts,
    required this.selectedFromId,
    required this.selectedToId,
    required this.type,
    required this.fromBalance,
    required this.tx,
    required this.error,
  });

  const NewTransactionState.initial()
      : loading = false,
        accounts = const [],
        selectedFromId = null,
        selectedToId = null,
        type = TransactionType.deposit,
        fromBalance = 0,
        tx = null,
        error = null;

  NewTransactionState copyWith({
    bool? loading,
    List<AccountEntity>? accounts,
    String? selectedFromId,
    String? selectedToId,
    TransactionType? type,
    double? fromBalance,
    TransactionEntity? tx,
    String? error,
    bool clearTx = false,
  }) {
    return NewTransactionState(
      loading: loading ?? this.loading,
      accounts: accounts ?? this.accounts,
      selectedFromId: selectedFromId ?? this.selectedFromId,
      selectedToId: selectedToId ?? this.selectedToId,
      type: type ?? this.type,
      fromBalance: fromBalance ?? this.fromBalance,
      tx: clearTx ? null : (tx ?? this.tx),
      error: error,
    );
  }
}

class NewTransactionCubit extends Cubit<NewTransactionState> {
  final BankingFacade facade;
  NewTransactionCubit(this.facade) : super(const NewTransactionState.initial());

  void init() {
    final accs = facade.getAccounts();
    final first = accs.isNotEmpty ? accs.first.id : null;

    emit(state.copyWith(
      accounts: accs,
      selectedFromId: first,
      fromBalance: first == null ? 0 : facade.getBalance(first),
      selectedToId: accs.length > 1 ? accs[1].id : null,
    ));
  }

  void selectFrom(String id) {
    String? to = state.selectedToId;
    if (state.type == TransactionType.transfer && to == id) {
      to = state.accounts.firstWhere((a) => a.id != id, orElse: () => state.accounts.first).id;
      if (to == id) to = null;
    }

    emit(state.copyWith(
      selectedFromId: id,
      selectedToId: to,
      fromBalance: facade.getBalance(id),
      error: null,
      clearTx: true,
    ));
  }

  void selectTo(String id) {
    emit(state.copyWith(selectedToId: id, error: null, clearTx: true));
  }

  void setType(TransactionType type) {
    emit(state.copyWith(type: type, error: null, clearTx: true));
  }

  void submit(double amount) {
    final fromId = state.selectedFromId;
    if (fromId == null) {
      emit(state.copyWith(error: 'Select an account first'));
      return;
    }

    emit(state.copyWith(loading: true, error: null, clearTx: true));

    final res = facade.submitTransaction(
      toAccountId: state.type == TransactionType.transfer ? state.selectedToId : null,
      type: state.type,
      amount: amount, fromAccountId: fromId,
    );

    res.when(
      success: (tx) {
        emit(state.copyWith(
          loading: false,
          tx: tx,
          fromBalance: facade.getBalance(fromId),
          error: null,
        ));
      },
      failure: (msg) => emit(state.copyWith(loading: false, error: msg)),
    );
  }
}
