import '../../presentation/factories.dart';
import '../chain/approval_handler.dart';
import '../chain/manager_approval_handler.dart';
import '../chain/teller_approval_handler.dart';
import 'banking_facade.dart';

class DefaultApprovalChainFactory implements ApprovalChainFactory {
  final double tellerAutoApproveLimit;
  final double managerLimit;

  DefaultApprovalChainFactory({
    this.tellerAutoApproveLimit = 1000,
    this.managerLimit = 10000,
  });

  @override
  ApprovalHandler create() {
    final teller = TellerApprovalHandler(maxAutoApprove: tellerAutoApproveLimit);
    final manager = ManagerApprovalHandler(maxManagerApprove: managerLimit);
    teller.setNext(manager);
    return teller;
  }
}
