import '../../models/article/event.dart';
import '../../models/user/authentication.dart';
import '../../models/user/interet.dart';
import '../../models/user/user.dart';
import '../../models/user/registerRequest.dart';

abstract class UserNetworkService {
  Future<User> seConnecter(Authentication authentication);
  Future<User> recupererInfoUtilisateur();
  Future<User> creerCompte(RegisterRequest registerRequest);
  Future<User> seDeconnecter();
  Future<List<Interet>> getInterets();
  Future<bool> verifierOtp({required String email, required String otp});
  Future<List<Event>> recupererFavEvents( String token);
}
