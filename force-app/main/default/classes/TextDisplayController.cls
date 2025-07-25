public class TextDisplayController {
    public String yourText { get; set; }

    public TextDisplayController() {
        String raw = 'LoremipsumdolorsitametconsecteturadipiscingelitNullaimperdietfelisnecvelitullamcorpervelviverraodiotinciduntMaecenassuscipitnuncvitainullaluctusinlaciniamassaefficiturPellentesquehabitantsenectusetnetusetmalesuadafamesacturpisegestasIntegertinciduntveliteumassatinciduntidfermentummagnaviverraDuissedloremidrismusladesultricesSedvehiculaloremidpurusdapibusatluctusodioegestasDonecultriciesnsilaposuerevestibulumlacusmagnaposuererosinscelerisquemagnaelaterosVivamusaccumsanturpisacsuscipitefficitureratleoscelerisquenibhincrursusnuncarcuatsemNullafacilisiAeneanportaorcinonnibhegestassedplaceratlacustemporSupercalifragilisticexpialidociousUnbreakableTextThatGoesOnAndOnWithoutSpacesJustToTestTheWrappingFunctionalityRightHereAtThisPointAndItStillKeepsGoingBecauseWeNeedMoreCharactersEndofteststring.';

        Integer chunkSize = 30;
        List<String> parts = new List<String>();

        for (Integer i = 0; i < raw.length(); i += chunkSize) {
            Integer endStr = Math.min(i + chunkSize, raw.length());
            parts.add(raw.substring(i, endStr) + '&#8203;'); // zero-width space
        }

        yourText = String.join(parts, '');
    }
}